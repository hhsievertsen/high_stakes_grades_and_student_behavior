/*
	Project: High School Grades 
	Purpose:  create Table 5
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"



cap program drop addscalar
program addscalar
	estadd scalar Clusters= e(N_clust)
	estadd scalar Observations= e(N)
	estadd scalar myr2=e(r2)
end
use "$tf\analysisdata.dta",clear
qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do" 
replace parents_schooling=. if parents_eduobs==0
replace parents_income=. if parents_incomeobs==0

* predict gpa
reg grades_postgrades_std `covars'
predict yhat,xb
label var yhat "Predicted GPA"
	* load locals
	qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
	eststo clear
	* loop over vars
	foreach var in  yhat child_std child_female      parents_schooling parents_income {
		qui: eststo: reghdfe   `var' grades_pregrades_transf_std `model'   , cluster(grades_schoolid)   absorb(grades_school)
		qui: addscalar
		qui: sum `var'
		qui: estadd scalar mymean=r(mean)
	}
	
	* make table
	esttab using "$df\tab_balanced_covars.tex", b(%4.3f) nonumbers nomtitles  keep(grades_pregrades_transf_std) star(* 0.1 ** 0.05 *** 0.01) replace fragment ///
					subs(mymean "Mean of dep. var" myr2 "R$^2$"Observations "\midrule Observations") nogaps se label stats(mymean Observations Clusters myr2,fmt(%4.2f %8.0fc %8.0fc %4.2f)) nolines 
	

