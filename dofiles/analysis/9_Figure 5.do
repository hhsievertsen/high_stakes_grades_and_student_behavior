/*
	Project: High School Grades 
	Purpose:  create Figure 5
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc

do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"	
/****************************************************************************/ 
cap program drop mygraph
program mygraph
syntax ,yvar(string) [graphoptions(string) female male]
	* dataset to save estimates
	clear
	set obs 3
	gen female=_n-1
	expand 4
	bys female: gen year=_n+2004
	qui: gen beta=.
	qui: gen lower=.
	qui: gen upper=.
	save "$tf\estimates.dta",replace
	
	*main
	use "$tf\analysisdata.dta",clear

		gen lr=child_enrolled_3_uni+child_enrolled_3_any

	if "`female'"!=""{
		keep if child_female==1
		}
	if "`male'"!=""{
		keep if child_female==0
		}

	local mylab: var label `yvar'
	di "`mylab'"
		qui: include  "x:\Data\workdata\704998\HighStakesGrades\dofiles\locals.do"
		qui: reghdfe `yvar' grades_pregrades_transf_std `model' `childcovars'   ,  cluster(grades_schoolid)   absorb(grades_schoolid)
		preserve
				use "$tf\estimates.dta",clear
				qui: replace beta= _b[grades_pregrades_transf_std] if year==2008
				qui: replace upper= _b[grades_pregrades_transf_std]+invttail(e(N),0.025)*_se[grades_pregrades_transf_std] if year==2008
				qui: replace lower= _b[grades_pregrades_transf_std]-invttail(e(N),0.025)*_se[grades_pregrades_transf_std] if year==2008
				save "$tf\estimates.dta",replace
		restore
	* placebo
		forval i=2005/2007{
		use "$tf\analysisdataplacebo`i'.dta",clear
	gen lr=child_enrolled_3_uni+child_enrolled_3_any

		if "`female'"!=""{
			keep if child_female==1
			}
		if "`male'"!=""{
			keep if child_female==0
			}
			
			qui: include  "x:\Data\workdata\704998\HighStakesGrades\dofiles\locals.do"
			qui: reghdfe `yvar' grades_pregrades_transf_std `model' `childcovars'  ,  cluster(grades_schoolid)   absorb(grades_schoolid)
			preserve 
				use "$tf\estimates.dta",clear
				qui: replace beta= _b[grades_pregrades_transf_std] if year==`i'
				qui: replace upper= _b[grades_pregrades_transf_std]+invttail(e(N),0.025)*_se[grades_pregrades_transf_std] if year==`i'
				qui: replace lower= _b[grades_pregrades_transf_std]-invttail(e(N),0.025)*_se[grades_pregrades_transf_std] if year==`i'
				save "$tf\estimates.dta",replace
			restore
			}
	* make figure
	
	use "$tf\estimates.dta",clear

	replace year=year-0.1 if female==0
	replace year=year+0.1 if female==1
	tw  (rcap upper lower  year if  year<2007.5 & female==2, lcolor(gs10) msymbol(d)) ///
		(scatter beta year if year<2007.5 & female==2, mcolor(gs10)  msymbol(d)) ///
		 (rcap upper lower  year if year>2007.5 & female==2, lcolor(black)  msymbol(d)) ///
		(scatter beta year if year>2007.5 & female==2, mcolor(black)  msymbol(d)) ///		
		,graphregion(lcolor(white) fcolor(white)) ///
		plotregion(lcolor(black) fcolor(white)) ///
		legend(off) ylabel(,noticks  labsize(medlarge)) `graphoptions' yline(0,lcolor(black)) ///
		xtitle(" ") ytitle("Coefficient", size(medlarge)) xlabel(2004.5 " " 2005 "2005" 2006 "2006" 2007 "2007" 2008 "2008" 2008.5 " ",  labsize(medlarge) noticks)
		graph export "$df\fig_placeboplot_`yvar'`male'`female'.pdf",replace
		graph export "$df\fig_placeboplot_`yvar'`male'`female'.png",replace width(2000)
end

	use "$tf\analysisdata.dta",clear
* Generate graphs
/* overall */

set trace off
mygraph ,yvar(grades_postgrades_std) graphoptions(ylabel(-.15(0.05)0.1,noticks))
mygraph ,yvar(child_enrolled_6_uni) graphoptions(ylabel(-.075(0.025)0.05,noticks))
mygraph ,yvar(child_graduated_6_uni) graphoptions(ylabel(-.075(0.025)0.05,noticks))
mygraph ,yvar(grades_postgrades_ext_std) graphoptions(ylabel(-.15(0.05)0.1,noticks))
mygraph ,yvar(grades_postgrades_int_std) graphoptions(ylabel(-.15(0.05)0.1,noticks))

/* female and amle */	
foreach gender in female male {
	mygraph ,yvar(grades_postgrades_std) graphoptions(ylabel(-.15(0.05)0.1,noticks)) `gender'
	mygraph ,yvar(child_enrolled_6_uni) graphoptions(ylabel(-.075(0.025)0.05,noticks)) `gender'
	mygraph ,yvar(child_graduated_6_uni) graphoptions(ylabel(-.075(0.025)0.05,noticks)) `gender'
	mygraph ,yvar(grades_postgrades_ext_std) graphoptions(ylabel(-.15(0.05)0.1,noticks)) `gender'
	mygraph ,yvar(grades_postgrades_int_std) graphoptions(ylabel(-.15(0.05)0.1,noticks)) `gender'

}	
