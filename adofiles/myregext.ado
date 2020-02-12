cap program drop addscalar
program addscalar
	estadd scalar Clusters= e(N_clust)
	estadd scalar Observations= e(N)
	estadd scalar myr2=e(r2)
end

capture program drop myregext
program myregext, 
	syntax varlist using, 
	* load locals
	qui: include  "x:\Data\workdata\704998\HighStakesGrades\dofiles\locals.do"
	eststo clear
	* main
	qui: eststo e1: reghdfe   `varlist' grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `varlist'
	qui: estadd scalar mymean=r(mean)
	* low gpa
	qui: eststo e2: reghdfe   `varlist'   grades_pregrades_transf_std `model' `covars' if child_lowgpa==1 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `varlist'  if child_lowgpa==1
	qui: estadd scalar mymean=r(mean)
	qui: eststo s1: reg   `varlist' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_lowgpa==1, 
	* high gpa
	qui: eststo s2: reg   `varlist' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_lowgpa==0, 
	qui: suest s1 s2, cluster(grades_schoolid)
	qui: test [s1_mean]grades_pregrades_transf_std=[s2_mean]grades_pregrades_transf_std
 	local myp=r(p)
	
	qui: eststo e3: reghdfe   `varlist'   grades_pregrades_transf_std `model' `covars' if child_lowgpa==0 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `varlist'  if child_lowgpa==0
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pval=`myp'
	
	* boys
	qui: eststo e4: reghdfe   `varlist'   grades_pregrades_transf_std `model' `covars' if child_female==0 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `varlist'  if child_female==0
	qui: estadd scalar mymean=r(mean)
	qui: eststo s1: reg   `varlist' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_female==0, 
	* girls
	qui: eststo s2: reg   `varlist' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_female==1, 
	qui: suest s1 s2, cluster(grades_schoolid)
	qui: test [s1_mean]grades_pregrades_transf_std=[s2_mean]grades_pregrades_transf_std
	local myp=r(p)
	
	qui: eststo e5: reghdfe   `varlist'   grades_pregrades_transf_std `model' `covars' if child_female==1 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `varlist'  if child_female==1 
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pval=`myp'
 
	
	* low edu
	qui: eststo e6: reghdfe   `varlist'   grades_pregrades_transf_std `model' `covars' if  parents_lowedu==1 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `varlist' if  parents_lowedu==1
	qui: estadd scalar mymean=r(mean)
	qui: eststo s1: reg   `varlist' grades_pregrades_transf_std `model' `covars'  i.grades_school if parents_lowedu==1, 
	* high edu
	qui: eststo s2: reg   `varlist' grades_pregrades_transf_std `model' `covars'  i.grades_school if parents_lowedu==0, 
	qui: suest s1 s2, cluster(grades_schoolid)
	qui: test [s1_mean]grades_pregrades_transf_std=[s2_mean]grades_pregrades_transf_std
	qui: local myp=r(p)
	qui: eststo e7: reghdfe   `varlist'   grades_pregrades_transf_std `model' `covars' if  parents_lowedu==0 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `varlist' if  parents_lowedu==0
	qui: estadd scalar mymean=r(mean) 
	qui: estadd  scalar pval=`myp'
 
	* make table
	esttab e1 e2 e3 e4 e5 e6 e7 `using', b(%4.3f) nonumbers nomtitles  keep(grades_pregrades_transf_std grades_pregrades_std c.grades_pregrades_std#c.grades_pregrades_std) star(* 0.1 ** 0.05 *** 0.01) replace fragment ///
					subs(mymean "Mean of dep. var" myr2 "R$^2$" pval "\midrule P-value") nogaps se label stats(mymean pval Observations Clusters myr2,fmt(%4.2f %4.2f %8.0fc %8.0fc %4.2f)) nolines 
	
end
