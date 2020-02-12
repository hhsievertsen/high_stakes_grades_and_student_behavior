/*
	Project: High School Grades 
	Data build sequence: 5/10
	Purpose: labour supply during high school
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* Labor supply during studies
 * loop over years
	forval i=4/7{
	* labor wage
		use "$rf\GRUND200`i'.dta", clear
		keep pnr loenmv
		gen wage=.
		replace wage=loenmv*(100/81.6)*.13*0.001 if `i'==3 /* fixed prices, euros, 1000 */
		replace wage=loenmv*(100/82.5)*.13*0.001 if `i'==4
		replace wage=loenmv*(100/84.0)*.13*0.001 if `i'==5
		replace wage=loenmv*(100/85.6)*.13*0.001 if `i'==6
		replace wage=loenmv*(100/87.1)*.13*0.001 if `i'==7
		drop loenmv
		save "$tf\labinc0`i'.dta", replace
	}
use "$tf\labinc04.dta",clear
gen grades_year=2005 /* labour income in calendar yar 2004 for those who graduated in 2005 */
forval i =5/7{
	append using "$tf\labinc0`i'.dta"
	replace grades_year=2001+`i' if grades_year==.
}
compress
replace wage=. if wage==0
save "$tf\labinc.dta",replace


