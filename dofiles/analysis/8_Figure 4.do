/*
	Project: High School Grades 
	Purpose:  create Figure 4
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"


clear 
set obs 6
gen year=_n
expand 2
bys year: gen female=_n-1
gen beta_grad_uni=.
gen beta_grad_any=.
gen beta_enrol_any=.
gen beta_enrol_uni=.
gen upper_grad_uni=.
gen upper_grad_any=.
gen upper_enrol_any=.
gen upper_enrol_uni=.
gen lower_grad_uni=.
gen lower_grad_any=.
gen lower_enrol_any=.
gen lower_enrol_uni=.
save "estimates.dta",replace


*main

/* save*/
cap program drop mysave
program mysave
	preserve
 use  "estimates.dta",clear
 replace beta_`1'=_b[grades_pregrades_transf_std] if year==`2' & female==`3'
 replace upper_`1'=_b[grades_pregrades_transf_std]+2*_se[grades_pregrades_transf_std] if year==`2' & female==`3'
 replace lower_`1'=_b[grades_pregrades_transf_std]-2*_se[grades_pregrades_transf_std] if year==`2' & female==`3'
 save "estimates.dta",replace
 restore
end
 
forval fem=0/1{
use "$tf\analysisdata.dta",clear
gen preshare=grades_ntretten/(grades_ntretten +grades_nsyv)
keep if child_female==`fem'
	forval i=1/6{
		replace child_graduated_`i'_any=child_graduated_`i'_any-child_graduated_`i'_uni
		replace child_enrolled_`i'_any=child_enrolled_`i'_any-child_enrolled_`i'_un
		qui: include  "x:\Data\workdata\704998\Gym_grading\dofiles\locals.do"
		qui:reghdfe   child_enrolled_`i'_any grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
		qui:mysave enrol_any `i' `fem'
		qui:reghdfe   child_enrolled_`i'_uni grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
		qui:mysave enrol_uni `i' `fem'
		qui:reghdfe   child_graduated_`i'_any grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
		qui:mysave grad_any `i' `fem'
		qui:reghdfe   child_graduated_`i'_uni grades_pregrades_transf_std `model' `covars'  , cluster(grades_schoolid)   absorb(grades_school)
		qui:mysave grad_uni `i' `fem'
	}
}

 use  "estimates.dta",clear
 forval fem=0/1{
 tw (connected beta_grad_uni year if fem==`fem', lcolor(black) lwidth(medthick) mcolor(black) msymbol(D) ) ///
    (rcap  upper_grad_uni  lower_grad_uni year if fem==`fem', lcolor(black) lwidth(medthick) ) ///
	(rcap  upper_grad_any  lower_grad_any year if fem==`fem', lcolor(gs10) lwidth(medthick) ) ///
    (connected beta_grad_any year if fem==`fem', lcolor(gs10) lwidth(medthick) mcolor(gs10) msymbol(S)) ///
	,graphregion(lcolor(white) fcolor(white)) ///
	plotregion(lcolor(black) fcolor(white)) ///
	ylabel(-0.08(0.02)0.08,noticks nogrid ) xlabel(,noticks) ///
	xtitle("Year after high school") ytitle(Coefficient on recoded GPA) yline(0,lcolor(black)) ///
	legend(order(4 "Any education, except university" 1 "University") region(lcolor(white) ))
	graph export "$df\fig_lr_grad_fem`fem'.pdf",replace
	graph export "$df\fig_lr_grad_fem`fem'.png",replace width(3000)
 tw (connected beta_enrol_uni year if fem==`fem', lcolor(black) lwidth(medthick) mcolor(black) msymbol(D) ) ///
    (rcap  upper_enrol_uni  lower_enrol_uni year if fem==`fem', lcolor(black) lwidth(medthick) ) ///
	(rcap  upper_enrol_any  lower_enrol_any year if fem==`fem', lcolor(gs10) lwidth(medthick) ) ///
    (connected beta_enrol_any year if fem==`fem', lcolor(gs10) lwidth(medthick) mcolor(gs10) msymbol(S)) ///
	,graphregion(lcolor(white) fcolor(white)) ///
	plotregion(lcolor(black) fcolor(white)) ///
	ylabel(-0.12(0.04)0.12,noticks nogrid ) xlabel(,noticks) ///
	xtitle("Year after high school") ytitle(Coefficient on recoded GPA) yline(0,lcolor(black)) ///
	legend(order(4 "Any education, except university" 1 "University") region(lcolor(white) ))
	graph export "$df\fig_lr_enrol_fem`fem'.pdf",replace
	graph export "$df\fig_lr_enrol_fem`fem'.png",replace width(3000)
}
