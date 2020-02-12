/*
	Project: High School Grades 
	Purpose:  create Figure 3
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"

*load data
use "$tf\analysisdata.dta",clear
* residualize
qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
qui: reg grades_pregrades_transf_std   `model' `covars'  i.grades_schoolid
qui: predict res,res
qui sum res, d
replace res=round(res,.01)
collapse (count) n=grades_pregrades_transf_std,by(res)
qui: sum n
gen frac=n/r(sum)
replace frac=. if n<4
qui: sum res if frac!=.
drop if res<r(min)  | res>r(max)
* save
keep frac res
rename res xhatr
save "$tf\histdata.dta",replace


/* non parametric approach */
use "$tf\analysisdata.dta",clear
qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
*residualize  x
qui: reg grades_pregrades_transf_std   `model' `covars'  i.grades_schoolid
qui: predict xhat,res
*residualize  yhat
qui: reg grades_postgrades_std   `model' `covars'  i.grades_schoolid
qui: predict yhat,res
/* estimate linear spec, predict and save confidence band */
reg yhat xhat
margins , at(xhat=(-1(0.1)1))
mat table=r(table)
mat yhat=table[1,1..21]'
mat upper=table[6,1..21]'
mat lower=table[5,1..21]'
svmat yhat ,names(yhat) 
svmat upper ,names(upper) 
svmat lower ,names(lower) 
gen xhat1=_n/10-1.1 if _n<22
/* splines */
mkspline _S=xhat, nknots(3) cubic
regress yhat _S*
predict yhat_splines
gen xhat_r=round(xhat,.05)
bys xhat_r: replace yhat_splines=. if _n>1
*local linear 
cap drop ylpoly xploly
lpoly yhat xhat , gen(xploly ylpoly) kernel(gaussian) deg(1) bwidth(0.5)
* merge with histogram
gen xhatr=round(xhat,.01)
merge m:1 xhatr using  "$tf\histdata.dta",nogen keep(1 3)
bys xhatr: gen show=_n==1
bys xhatr: egen s=sum(yhat)
* Fig 1: splines 	
sum xhatr,d
local bound=r(p99)
local bound2=.15
tw  (bar frac xhatr if show==1 & xhatr>-`bound' & xhatr<`bound' , barwidth(0.01) fcolor(gs13) lcolor(gs13) yaxis(2)) ///
	(rarea upper lower xhat1  if xhat1>-`bound' & xhat1<`bound' ,sort fcolor(gs8)  lcolor(gs12)  lwidth(thin) )  /// /*confidence band */
	(line yhat1 xhat1 if xhat1>-`bound' & xhat1<`bound' ,sort lcolor(black)  lwidth(medthick ))  /// /* linear */
	(line yhat_splines xhat if xhat>-`bound'& xhat<`bound',sort  lcolor(black) lpattern(dash) lwidth(medthick) ) ///  /*splie */
	, graphregion(lcolor(white) fcolor(white))  plotregion(lcolor(black) fcolor(white)) ///
	ylabel(-`bound2'(0.05)`bound2',noticks nogrid ) ylabel(,noticks axis(2)) xlabel(-.6(0.2).6,noticks) ///
	xtitle("Recoded GPA (residualized)") ytitle("GPA after recoding (residualized)") ytitle("Share (residualized recoding)",axis(2)) ///
	legend(order(3 "Linear fit" 4 "Natural cubic spline") region(lcolor(white))) ///
	 yscale(noline) xscale(noline) note("Note: Cells based on less than 4 observations are not shown")
	graph export "$df\fig_np_splines.pdf",replace

* Fig 2: llr 	
local bound=.81
local bound2=.15
tw  (bar frac xhatr if show==1 & xhatr>-`bound' & xhatr<`bound' , barwidth(0.01) fcolor(gs13) lcolor(gs13) yaxis(2)) ///
	(rarea upper lower xhat1  if xhat1>-`bound' & xhat1<`bound' ,sort fcolor(gs8)  lcolor(gs12)  lwidth(thin) )  /// /*confidence band */
	(line yhat1 xhat1 if xhat1>-`bound' & xhat1<`bound' ,sort lcolor(black)  lwidth(medthick ))  /// /* linear */
	(line ylpoly xploly if xploly>-`bound' & xploly<`bound' ,sort lcolor(black) lpattern(dash)  lwidth(medthick ))  /// * lpoly /
	, graphregion(lcolor(white) fcolor(white))  plotregion(lcolor(black) fcolor(white)) ///
	ylabel(-`bound2'(0.05)`bound2',noticks nogrid ) ylabel(,noticks axis(2)) xlabel(-.6(0.2).6,noticks) ///
	xtitle("Recoded GPA (residualized)") ytitle("GPA after recoding (residualized)") ytitle("Share (residualized recoding)",axis(2)) ///
	legend(order(3 "Linear fit" 4 "Local linear regression") region(lcolor(white))) ///
	 yscale(noline) xscale(noline) note("Note: Cells based on less than 4 observations are not shown")
	graph export "$df\fig_np_llr.pdf",replace
	
