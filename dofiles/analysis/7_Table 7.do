/*
	Project: High School Grades 
	Purpose:  create Table 7
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"

/****************************************************************************/
cap program drop mysave
program mysave
syntax,name(string) [replace append]
label var grades_pregrades_transf_std "`name'"
esttab using "$df\tab_robust.tex",b(%4.3f) nonumbers nomtitles  keep(grades_pregrades_transf_std) ///
					nostar `replace' `append' fragment ///
					 nogaps se label  nolines  noobs
eststo clear					 
end


use "$tf\analysisdata.dta",clear

/* share recoded */
gen preshare=grades_ntretten/(grades_ntretten +grades_nsyv)
sum preshare,d
gen share_recoded=preshare<r(p50)

* run specifications
	* load locals
	qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
	eststo clear
	* Main
	qui: eststo: reg   grades_postgrades_std grades_pregrades_transf_std   `model'  `covars'  , cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, replace name("Main spec")	
	* no covars
	qui: eststo: reg   grades_postgrades_std grades_pregrades_transf_std   `model'  , cluster(grades_schoolid) 
	mysave, append  name("No covariates")	
	* linear
	qui: eststo: reghdfe   grades_postgrades_std grades_pregrades_transf_std   `covars' grades_pregrades_std , cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, append name("Linear specification")
	* cubic
	qui: eststo: reghdfe   grades_postgrades_std grades_pregrades_transf_std   `covars' grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std#c.grades_pregrades_std , cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, append name("Quadratic specification")
	* interacted with high school
	qui: eststo: reghdfe   grades_postgrades_std grades_pregrades_transf_std   `covars' grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std grades_schoolid#c.grades_pregrades_std grades_schoolid#c.grades_pregrades_std#c.grades_pregrades_std , cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, append name("School specific polynomials")
	* program fixed effect
	qui: eststo: reghdfe   grades_postgrades_std grades_pregrades_transf_std i.grades_blevels i.grades_alevels grades_alevel_mat   `covars'  grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std  , cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, append name("Subject and level fixed effects.")
	* condition on share recoded
	qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
	qui: eststo: reghdfe   grades_postgrades_std grades_pregrades_transf_std   `covars' grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std share_recoded, cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, append name("Condition on share of grades recoded.")
	* including delayed
	use "$tf\analysisdata_later.dta",clear
	qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
	qui: eststo: reghdfe   grades_postgrades_std grades_pregrades_transf_std   `covars' grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std , cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, append name("Including delayed students.")
	* no outliers 
	use "$tf\analysisdata.dta",clear
	qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
	reg grades_pregrades_transf_std `model'
	predict res,
	qui: sum res, d
	drop if res<r(p1) | res>r(p99)
	qui: eststo: reghdfe   grades_postgrades_std grades_pregrades_transf_std   `covars' grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std , cluster(grades_schoolid) absorb(grades_schoolid)
	mysave, append name("No outliers (top and bottom 1pct excluded.")
	