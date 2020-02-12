/*
	Project: High School Grades 
	Purpose:  create Figure 2
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* load data
use "$tf\analysisdata.dta",clear
/* program to create graphs */	
cap program drop mygraph
program mygraph
	syntax, v1(string) v2(string)  rlevel(string) rlevel1(string) minobs(string) [r1(string) yname1(string) name(string) yname2(string) x1(string) x2(string) ]
	preserve 
	/* calulate stuff */
		* keep variables
			keep `v2' `v1' grades_nsyv
		* derive old gpa  and new gpa combinations
			gen pre=round(`v1',`rlevel')
			gen post=round( `v2',`rlevel')
			sort pre post
			by pre post: egen obs=count(grades_nsyv)
			by pre post: gen show=_n==1&obs>`minobs'
		* calculate shares
			by pre: egen obs_pre=count(grades_nsyv)
			by pre : gen show_pre=_n==1&obs_pre>`minobs'
			qui: sum pre
			gen preshare=obs_pre/r(N)
		* fitted line
			qui: reg `v2' `v1'  c.`v1'#c.`v1'
			qui:predict yhat, xb
			qui:predict res, res
		 * calculate shares residual
			gen res_r=round(res,`rlevel1')
			sort res_r
			by res_r: egen obs_res=count(grades_nsyv)
			by res_r : gen show_res=_n==1&obs_res>`minobs'
			qui: sum res_r
			gen resshare=obs_res/r(N) 
		* derive old gpa  and residaul combinations
			sort pre res_r
			by pre res_r: egen obs_rt=count(grades_nsyv)
			by pre res_r: gen show_rt=_n==1&obs_rt>`minobs'
	/* create plots */
	* plot locals
	  local po="graphregion(lcolor(white) fcolor(white)) plotregion(lcolor(black) fcolor(white))   legend(off)"
		* Plot 1:  Pre and post recoding gpa 
		tw (scatter post pre if show==1,msymbol(X) mcolor(black)) ///
		   (qfit  `v2' `v1' `r1',  lpattern(dash) lcolor(black)) ///
		   ,ylabel(`yname1',noticks) xlabel(`x1',noticks) `po' ///
		   xtitle("13-scale GPA `name'") ytitle("7-scale GPA (recoded) `name'") 
		   graph export "$df\fig`name'a.pdf",replace
		* Plot 4: histogram of residuals 
		 tw (bar resshare res_r if show_res==1 & res_r>-1.5 & res_r<1.5, barwidth(`rlevel1') lcolor(white) fcolor(gs10) )  ///
		   ,ylabel(#7,noticks) xlabel(`x2',noticks) `po' ///
		   legend(off) xtitle("Residual `name'") ytitle("Share") 
		   graph export "$df\fig`name'b.pdf",replace		
		restore
end		  
		   

* load data
use "$tf\analysisdata.dta",clear
/* Figure 2 */
mygraph, yname2("-1.25(0.25)1.25") x2("-0.75(0.25)0.75") x1("-4(2)4") yname1("-4(2)4") name(1) rlevel(0.25) rlevel1(0.05) minobs(4)  r1(if grades_pregrades_std>-4 & grades_pregrades_std<4) v1(grades_pregrades_std) v2(grades_pregrades_transf_std)	
/* Figure A.5 */

/* create raw graphs */
mygraph, x2("-1.5(0.3)1.5") yname1(-2(2)12) rlevel(0.25) rlevel1(0.1) minobs(2)  name(2) r1(if grades_pregrades>4 & grades_pregrades<12) v1(grades_pregrades) v2(grades_pregrades_transf)


