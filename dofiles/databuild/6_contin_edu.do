/*
	Project: High School Grades 
	Data build sequence: 6/10
	Purpose:  enrollment and graduation after high school
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
/****************************************************************************/
* Enrol
	use "$rf\KOTRE2014.dta", clear
	* get labels
	destring udd, replace
	merge m:1 udd using "$formats\uddan_2014_udd.dta", keep(1 3) nogen
	destring h1, replace
	* keep  programs
	keep if h1>=35 & h1<70
	* keep what we need
	keep ELEV3_VFRA pnr h1
	save "$tf\kotre2014.dta",replace
* Enrolled 
	forval i=2003/2014{
		* load data
		use "$tf\kotre2014.dta", clear
		* only if enrolled in year
		keep if year(ELEV3_VFRA)==`i' 
		* only keep only one obs (obs: they could in principle graduate from more programs in year, but very few)
		bys pnr: keep if _n==1
		keep pnr h1
		if `i'==2003{
			gen year=`i'
			save "$tf\enroldata.dta",replace
			
		}
		else{
			gen year=`i'
			append using "$tf\enroldata.dta",
			save "$tf\enroldata.dta",replace
				}
	}
/****************************************************************************/	
* Graduate
	use "$rf\KOTRE2014.dta", clear
	* only completed programs
	drop if audd==0|audd==9999
	* get labels
	tostring audd, replace
	merge m:1 audd using "$formats\uddan_2014_audd.dta", keep(1 3) nogen
	destring h1, replace
	* keep what we need
	keep ELEV3_VTIL pnr h1
	save "$tf\kotre2014.dta",replace
*loop over years (find who graduated each year and keep these pnr)
	forval i=2003/2014{
		* load data
		use "$tf\kotre2014.dta", clear
		* only if graduated directly in year
		keep if year(ELEV3_VTIL)==`i' 
		* only keep only one obs (obs: they could in principle graduate from more programs in year, but very few)
		bys pnr: keep if _n==1
		keep pnr h1
		if `i'==2003{
			gen year=`i'
			save "$tf\graddata.dta",replace
			
		}
		else{
			gen year=`i'
			append using "$tf\graddata.dta",
			save "$tf\graddata.dta",replace
			}
	}
	
