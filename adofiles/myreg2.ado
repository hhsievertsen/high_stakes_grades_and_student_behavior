cap program drop addscalar
program addscalar
	estadd scalar Clusters= e(N_clust)
	estadd scalar Observations= e(N)
	estadd scalar myr2=e(r2)
end

capture program drop myreg2
program myreg2, 
	syntax  using, var1(string) var2(string)
/* VAR 1*/
	* load locals
	qui: include  "x:\Data\workdata\704998\HighStakesGrades\dofiles\locals.do"
	eststo clear
	* main
	qui: eststo e1: reghdfe   `var1' grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var1'
	qui: estadd scalar mymean=r(mean)
	qui: eststo s0: reg   `var1' grades_pregrades_transf_std `model' `covars'  i.grades_school, 
	* low gpa
	qui: eststo e2: reghdfe   `var1'   grades_pregrades_transf_std `model' `covars' if child_lowgpa==1 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var1'  if child_lowgpa==1
	qui: estadd scalar mymean=r(mean)
	qui: eststo s1: reg   `var1' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_lowgpa==1, 
	* high gpa
	qui: eststo s2: reg   `var1' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_lowgpa==0, 
	qui: suest s1 s2, cluster(grades_schoolid)
	qui: test [s1_mean]grades_pregrades_transf_std=[s2_mean]grades_pregrades_transf_std
 	local myp=r(p)
	
	qui: eststo e3: reghdfe   `var1'   grades_pregrades_transf_std `model' `covars' if child_lowgpa==0 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `var1'  if child_lowgpa==0
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pval=`myp'
	
	* boys
	qui: eststo e4: reghdfe   `var1'   grades_pregrades_transf_std `model' `covars' if child_female==0 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var1'  if child_female==0
	qui: estadd scalar mymean=r(mean)
	qui: eststo s3: reg   `var1' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_female==0, 
	* girls
	qui: eststo s4: reg   `var1' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_female==1, 
	qui: suest s3 s4, cluster(grades_schoolid)
	qui: test [s3_mean]grades_pregrades_transf_std=[s4_mean]grades_pregrades_transf_std
	local myp=r(p)
	
	qui: eststo e5: reghdfe   `var1'   grades_pregrades_transf_std `model' `covars' if child_female==1 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `var1'  if child_female==1 
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pval=`myp'
 
	
	* low edu
	qui: eststo e6: reghdfe   `var1'   grades_pregrades_transf_std `model' `covars' if  parents_lowedu==1 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var1' if  parents_lowedu==1
	qui: estadd scalar mymean=r(mean)
	qui: eststo s5: reg   `var1' grades_pregrades_transf_std `model' `covars'  i.grades_school if parents_lowedu==1, 
	* high edu
	qui: eststo s6: reg   `var1' grades_pregrades_transf_std `model' `covars'  i.grades_school if parents_lowedu==0, 
	qui: suest s5 s6, cluster(grades_schoolid)
	qui: test [s5_mean]grades_pregrades_transf_std=[s6_mean]grades_pregrades_transf_std
	qui: local myp=r(p)
	qui: eststo e7: reghdfe   `var1'   grades_pregrades_transf_std `model' `covars' if  parents_lowedu==0 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `var1' if  parents_lowedu==0
	qui: estadd scalar mymean=r(mean) 
	qui: estadd  scalar pval=`myp'
 
	* make table
	esttab e1 e2 e3 e4 e5 e6 e7 `using', b(%4.3f) nonumbers nomtitles  keep(grades_pregrades_transf_std) star(* 0.1 ** 0.05 *** 0.01) replace fragment ///
					subs(mymean "Mean of dep. var" myr2 "R$^2$" pval "\midrule P-value") nogaps se label stats(mymean pval Observations Clusters myr2,fmt(%4.2f %4.2f %8.0fc %8.0fc %4.2f)) nolines 
/* VAR 2*/
	* load locals
	qui: include  "x:\Data\workdata\704998\HighStakesGrades\dofiles\locals.do"
/* OVERALL */
	qui: eststo s0_b: reg   `var2' grades_pregrades_transf_std `model' `covars'  i.grades_school , 
	* TEST ACROSS ROWS!
	qui: suest s0 s0_b, cluster(grades_schoolid)
	qui: test [s0_mean]grades_pregrades_transf_std=[s0_b_mean]grades_pregrades_transf_std
	qui: local mypA=r(p)
	* MAIN ESTIMATE
	qui: eststo e1_b: reghdfe   `var2' grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var2'
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pvalA=`mypA'
	
/* LOW GPA*/
	*TEST ACROSS ROWS!
	qui: eststo s1_b: reg   `var2' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_lowgpa==1, 
	qui: suest s1 s1_b, cluster(grades_schoolid)
	qui: test [s1_mean]grades_pregrades_transf_std=[s1_b_mean]grades_pregrades_transf_std
	qui: local mypA=r(p)
	* MAIN ESTIMATE
	qui: eststo e2_b: reghdfe   `var2'   grades_pregrades_transf_std `model' `covars' if child_lowgpa==1 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var2'  if child_lowgpa==1
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pvalA=`mypA'
	
/* HIGH GPA*/
	*TEST ACROSS ROWS!
	qui: eststo s2_b: reg   `var2' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_lowgpa==0, 
	qui: suest s2 s2_b, cluster(grades_schoolid)
	qui: test [s2_mean]grades_pregrades_transf_std=[s2_b_mean]grades_pregrades_transf_std
	qui: local mypA=r(p)
	*TEST ACROSS COLUMNS!
	qui: suest s1_b s2_b, cluster(grades_schoolid)
	qui: test [s1_b_mean]grades_pregrades_transf_std=[s2_b_mean]grades_pregrades_transf_std
 	local myp=r(p)
	*MAIN ESTIMATE!
	qui: eststo e3_b: reghdfe   `var2'   grades_pregrades_transf_std `model' `covars' if child_lowgpa==0 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `var2'  if child_lowgpa==0
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pval=`myp'
	qui: estadd  scalar pvalA=`mypA'
	
/*  BOYS */
	*TEST ACROSS ROWS!
	qui: eststo s3_b: reg   `var2' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_female==0, 
	qui: suest s3 s3_b, cluster(grades_schoolid)
	qui: test [s3_mean]grades_pregrades_transf_std=[s3_b_mean]grades_pregrades_transf_std
	qui: local mypA=r(p)
	* MAIN ESTIMATE
	qui: eststo e4_b: reghdfe   `var2'   grades_pregrades_transf_std `model' `covars' if child_female==0 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var2'  if child_female==0
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pvalA=`mypA'

/*  GIRLS */
	*TEST ACROSS ROWS!
	qui: eststo s4_b: reg   `var2' grades_pregrades_transf_std `model' `covars'  i.grades_school if child_female==1, 
	qui: suest s4 s4_b, cluster(grades_schoolid)
	qui: test [s4_mean]grades_pregrades_transf_std=[s4_b_mean]grades_pregrades_transf_std
	qui: local mypA=r(p)
	* TEST ACROSS COLUMNS 
	qui: suest s3_b s4_b, cluster(grades_schoolid)
	qui: test [s3_b_mean]grades_pregrades_transf_std=[s4_b_mean]grades_pregrades_transf_std
	local myp=r(p)
	* MAIN ESTIMATE
	qui: eststo e5_b: reghdfe   `var2'   grades_pregrades_transf_std `model' `covars' if child_female==1 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `var2'  if child_female==1 
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pval=`myp'
	qui: estadd  scalar pvalA=`mypA'
	
* LOW EDU
	*TEST ACROSS ROWS!
	qui: eststo s5_b: reg   `var2' grades_pregrades_transf_std `model' `covars'  i.grades_school if parents_lowedu==1, 
	qui: suest s5 s5_b, cluster(grades_schoolid)
	qui: test [s5_mean]grades_pregrades_transf_std=[s5_b_mean]grades_pregrades_transf_std
	qui: local mypA=r(p)
	*MAIN ESTIMATE
	qui: eststo e6_b: reghdfe   `var2'   grades_pregrades_transf_std `model' `covars' if  parents_lowedu==1 , cluster(grades_schoolid)   absorb(grades_school)
	qui: addscalar
	qui: sum `var2' if  parents_lowedu==1
	qui: estadd scalar mymean=r(mean)
	qui: estadd  scalar pvalA=`mypA'
* HIGH EDU
	*TEST ACROSS ROWS!
	qui: eststo s6_b: reg   `var2' grades_pregrades_transf_std `model' `covars'  i.grades_school if parents_lowedu==0, 
	qui: suest s6 s6_b, cluster(grades_schoolid)
	qui: test [s6_mean]grades_pregrades_transf_std=[s6_b_mean]grades_pregrades_transf_std
	qui: local mypA=r(p)
	*TEST ACROSS COLUMNS!
	qui: suest s5_b s6_b, cluster(grades_schoolid)
	qui: test [s5_b_mean]grades_pregrades_transf_std=[s6_b_mean]grades_pregrades_transf_std
	qui: local myp=r(p)
	* MAIN ESTIMATE
	qui: eststo e7_b: reghdfe   `var2'   grades_pregrades_transf_std `model' `covars' if  parents_lowedu==0 , cluster(grades_schoolid)   absorb(grades_school)  
	qui: addscalar
	qui: sum `var2' if  parents_lowedu==0
	qui: estadd scalar mymean=r(mean) 
	qui: estadd  scalar pval=`myp'
	qui: estadd  scalar pvalA=`mypA'
 
/* Test across models */
	
	

	* make table
	esttab e1_b e2_b e3_b e4_b e5_b e6_b e7_b `using', b(%4.3f) nonumbers nomtitles  keep(grades_pregrades_transf_std) star(* 0.1 ** 0.05 *** 0.01) append fragment ///
					subs(mymean "Mean of dep. var" myr2 "R$^2$" pval "\midrule P-value" pvalA "P-value rows") nogaps se label stats(mymean pval pvalA Observations Clusters myr2,fmt(%4.2f %4.2f %4.2f  %8.0fc %8.0fc %4.2f)) nolines 
end
