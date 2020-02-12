/*
	Project: High School Grades 
	Purpose:  create Figure A2
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc

do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"	
/*****************************************************************************/
	use  "$tf\gpa.dta",clear
	* drop HF for now
	keep if inlist(udd,1145,1146,1199,5080,5090)
	* make graphs
	rename child_hsgpa gpa
	keep gpa grades_year
	rename grades_year year
	tw  		(kdensity gpa if year==2003, kernel(tri) bwidth(0.4) lpattern(dash) lcolor(gs14)) ///
		   (kdensity gpa if year==2004, kernel(tri) bwidth(0.4) lpattern(dash) lcolor(gs11)) ///
		   (kdensity gpa if year==2005, kernel(tri) bwidth(0.4) lpattern(dash) lcolor(gs8)) ///
		   (kdensity gpa if year==2006, kernel(tri) bwidth(0.4) lpattern(dash) lcolor(gs5)) ///
		   (kdensity gpa if year==2007, kernel(tri) bwidth(0.4) lpattern(dash) lcolor(gs2)) ///
		   (kdensity gpa if year==2008, kernel(tri) bwidth(0.4) lcolor(gs12)) ///
		   (kdensity gpa if year==2009, kernel(tri) bwidth(0.4) lcolor(gs10)) ///
		   (kdensity gpa if year==2010, kernel(tri) bwidth(0.4) lcolor(gs8)) ///
		   (kdensity gpa if year==2011, kernel(tri) bwidth(0.4) lcolor(gs6)) ///
		   (kdensity gpa if year==2012, kernel(tri) bwidth(0.4) lcolor(gs4)) ///
		   (kdensity gpa if year==2013, kernel(tri) bwidth(0.4) lcolor(gs2)) ///
		   (kdensity gpa if year==2, kernel(tri) bwidth(0.4) lcolor(white)) ///
		   (kdensity gpa if year==1, kernel(tri) bwidth(0.4) lcolor(white)) ///
		   , legend(order(12 "Old:"1 "2003" 5 "2007" 13 "New:"6 "2008" 11 "2013")  rows(2) region(lcolor(white))) ///
		   graphregion(lcolor(white) fcolor(white)) plotregion(lcolor(black) fcolor(white)) ///
		   xtitle("High school GPA") ytitle(Density) 
		   graph export "$df\fig_hs_distribution.pdf",replace
