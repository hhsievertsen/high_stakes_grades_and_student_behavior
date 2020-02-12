/*
	Project: High School Grades 
	Purpose:  create Figure A9
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"


* dropoutrates by year
	use "$tf\dropoutsraw.dta",clear
	drop if ontime==1
	collapse (count) n=ontime, by(enrollmentyear highdel)
	bys enrol: egen total=sum(n)
	tw  (connected n enrollmentyear if highdel==1,lcolor(black) msymbol(x) mcolor(black) msize(medlarge)) ///
		(connected n enrollmentyear if highdel==2,lcolor(black) msymbol(d) mcolor(black) msize()) ///
		(connected n enrollmentyear if highdel==3,lcolor(black) msymbol(s) mcolor(black) msize()) ///
		(line total enrollmentyear if highdel==3,lcolor(black) ) ///
		, graphregion(lcolor(white) fcolor(white))  plotregion(lcolor(black) fcolor(white)) ///
		legend(order(4 "All" 1 "Year one" 2 "Year two" 3 "Year three") ///
		 region(lcolor(white)) rows(3)) xtitle(Enrollment year) ytitle(Students) ///
		 xline(2005,lcolor(black) lpattern(dash))
		 graph export "$df\fig_dropoutratesovertime_byyear.pdf",replace
		 graph export "$df\fig_dropoutratesovertime_byyear.png",replace width(2000)
