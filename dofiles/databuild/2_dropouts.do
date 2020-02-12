/*
	Project: High School Grades 
	Data build sequence: 2/10
	Purpose: identify delays/dropouts
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
	do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* load education register
	use "$rf\KOTRE2014.dta", clear
* only keep relevant degrees
	destring udd, replace
	merge m:1 udd using "$formats\uddan_2014_udd.dta", nogen keep(1 3)
	keep if h1=="20" | h1=="25"
	drop if inlist(udd,1539,1652,1879,1889,1891,1895,4007,4031,4008,5045,5126,5230,1899,5299)
* enrollment year in degree
	bys pnr udd: egen enrollmentyear=min(year(ELEV3_VFRA))
* deleayed study
	gen delayed=0
	replace delayed=3 if udel-(year(ELEV3_VFRA)-enrollmentyear+1)<0 & udel==3
	replace delayed=2 if udel-(year(ELEV3_VFRA)-enrollmentyear+1)<0 & udel==2
	replace delayed=1 if udel-(year(ELEV3_VFRA)-enrollmentyear+1)<0 & udel==1
	replace delay=.    if del==0
	replace delay=udel if audd==0 & delay==.
	sort pnr udd
	by pnr udd: egen highdel=min(delayed)
	by pnr udd: egen maxachi=max(udel)
	by pnr udd: egen dropoutdate=max(ELEV3_VTIL)
	gen grades_schoolid=instnr if udel==maxach
* graduation 
	gen gy=.
	replace gy=year(ELEV3_VTIL) if AFG_ART==11 & audd!=0
	bys pnr udd: egen graduationyear=max(gy)
	gen time=graduationyear-enrollmentyear
	gen ontime=time<4
* collapse
	collapse (min) ontime highdel maxachi grades_schoolid dropoutdate, by(pnr udd enrollmentyear)
	keep if enrollmen>1999 & enrollmen<2011
	replace highdel=max if highdel==. & ontime==0
	drop max
	save "$tf\dropoutsraw.dta",replace 
* data for merge
	gen year=enrol+3
	keep if year>2002 & year<2009
	rename highdel dropout
	keep if ontime==0
	keep pnr year dropout grades
	rename year grades_year
	compress
	save "$tf\dropouts.dta",replace
