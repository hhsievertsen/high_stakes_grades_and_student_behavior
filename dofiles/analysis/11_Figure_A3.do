/*
	Project: High School Grades 
	Purpose:  create Figure A3
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc

do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"	
/****************************************************************************/ 
* load data and set missing values from  zeros to missing
	use "$tf\analysisdata.dta",clear
	preserve
		collapse (count) n_13=grades_passed, by (grades_ntretten)
		rename grades_ntretten grades
		save "$tf\grades_13.dta", replace
	restore
	collapse (count) n_7=grades_passed, by (grades_nsyv)
	rename grades_nsyv grades
	merge 1:1 grades using "$tf\grades_13.dta", nogen
	sum n_13
	di r(sum)
	replace n_7=100*n_7/r(sum)
	replace n_13=100*n_13/r(sum)
* Make plot
		tw (bar n_13 grades, fcolor(black) lcolor(white)) (bar n_7 grades, fcolor(gs6)  lcolor(white) ) ///
		  ,graphregion(lcolor(white) fcolor(white)) plotregion(lcolor(black) fcolor(white)) ///
		   xtitle("Number of grades given") ytitle("Share (percent)")  legend(order(1 "Pre transformation" ///
		   2 "Post transformation") region(lcolor(white)))
		   graph export "$df\fig_grades_given_distribution.pdf",replace
