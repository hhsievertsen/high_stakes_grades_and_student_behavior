/*
	Project: High School Grades 
	Purpose:  create Table 4
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"



* Table 4
use "$tf\analysisdata.dta",clear
qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
eststo clear
foreach var in grades_blevels grades_alevels grades_alevel_mat{
	eststo: reghdfe  `var'  grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
	qui: estadd scalar Clusters= e(N_clust)
	qui: estadd scalar Observations= e(N)
	qui: estadd scalar myr2=e(r2)
	qui: sum grades_blevels `var' 
	qui: estadd scalar mymean=r(mean)
}	
esttab using "$df\tab4.tex", b(%4.3f) nonumbers nomtitles  keep(grades_pregrades_transf_std) star(* 0.1 ** 0.05 *** 0.01) replace fragment ///
					subs(mymean "Mean of dep. var" myr2 "R$^2$" pval "\midrule P-value") nogaps se label stats(mymean pval  Observations Clusters myr2,fmt(%4.2f %4.2f  %8.0fc %8.0fc %4.2f)) nolines 
	


