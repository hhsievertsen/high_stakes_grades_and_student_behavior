/*
	Project: High School Grades 
	Data build sequence: 8/10
	Purpose:  merge data
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* load grading data
	use  "$tf\gradingdata.dta",clear
* append dropouts
	append using "$tf\dropouts.dta"
	gen selection_dropouts=dropout!=.
	replace dropout=0 if dropout==.
	rename dropout child_dropoutyear
	replace grades_placebo=1 if grades_year<2008
	drop if grades_year<2005
* remove nontreated later
	drop if grades_ntretten==0 | grades_nsyv==0
* merge with high school data
	destring udd, replace
	merge m:1 pnr udd grades_year using "$tf\gpa.dta", nogen keep(1 3)
* merge with primary school data
	merge m:1 pnr using "$tf\udfk.dta", nogen keep(1 3)
* merge with child data
	merge m:1 pnr using "$tf\childdata.dta", nogen keep(1 3)
* define age at graduation
	gen child_age=(mdy(8,1,grades_year-3)-dateofbirth)/365.25
	* rename
	foreach l in nonwestern  female dateofbirth{
		rename `l' child_`l'
	}		
* merge with labor supply
	merge m:1 pnr grades_year using "$tf\labinc.dta", keep(1 3) nogen
	rename wage  child_2ndyear_laborinc
	gen child_2ndyear_worked=child_2ndyear_laborinc!=.
* Long run outcomes	
gen year=grades_year
forval y=1/6{
	/* Enrol */
	replace year=year+1
	merge m:1 pnr year using "$tf\enroldata.dta",keep(1 3) nogen
	gen child_enrolled_`y'_any=inlist(h1,30,35,40,50,60,65,70)
	gen child_enrolled_`y'_uni=inlist(h1,60,65,70)
	drop h1
	/* Graduated */
	di `y'
	merge m:1 pnr year using "$tf\graddata.dta",keep(1 3) nogen
	gen child_graduated_`y'_any=inlist(h1,30,35,40,50,60,65,70)
	gen child_graduated_`y'_uni=inlist(h1,60,65,70)
	drop h1
}
	/* Make cumulative */
forval i=2/6{
	local j=`i'-1
	/* Enrol */
	replace child_enrolled_`i'_any=1 if child_enrolled_`j'_any==1
	replace child_enrolled_`i'_uni=1 if child_enrolled_`j'_uni==1
	/* Graduated */
	replace child_graduated_`i'_any=1 if child_graduated_`j'_any==1
	replace child_graduated_`i'_uni=1 if child_graduated_`j'_uni==1
}
* Merge with parent data
	gen holder=pnr
	gen t=grades_year-4
	foreach l in `l' father mother {
		replace pnr=`l'_id
		merge m:1 pnr t using "$tf\parcovars.dta", keep(1 3) nogen
		rename schooling `l'_schooling
		rename income `l'_income
		drop dateofbirth 
	}
	replace pnr=holder
* save data and clean up
	rename udd grades_udd
	rename pnr child_id
	order child* grades* father* mother* 
	compress
	drop holder    t    
	save "$tf\rawdata.dta",replace
	
		
