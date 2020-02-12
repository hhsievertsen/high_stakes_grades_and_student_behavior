/*
	Project: High School Grades 
	Purpose:  create Table 6, 8
	note: myreg, myregext and myreg2 are defined separately

	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\\dofiles\settings.do"

*Table 6
use "$tf\analysisdata.dta",clear
gen preshare=grades_ntretten/(grades_ntretten +grades_nsyv)
myreg grades_postgrades_std using "$df\tab_main.tex"


*Table 8
myreg2  using "$df\tab_teachbevh.tex", var2(grades_postgrades_ext_std) var1(grades_postgrades_int_std)


*Table 9
myreg child_graduated_6_uni using "$df\tab_longrun_uni_grad.tex"
myreg child_enrolled_6_uni using "$df\tab_longrun_uni_enr.tex"

* Table A1
use "$tf\analysisdata_later.dta",clear
gen preshare=grades_ntretten/(grades_ntretten +grades_nsyv)
gen grades_late=grades_year>2008
myreg grades_late using "$df\tab_lates.tex"

* Table A2
myregext grades_postgrades_std using "$df\tab_main_appendix.tex"

* Table A3
myreg child_2ndyear_worked using "$df\tab_lab_extensive.tex"
myreg child_2ndyear_laborinc using "$df\tab_lab_intensive.tex"

