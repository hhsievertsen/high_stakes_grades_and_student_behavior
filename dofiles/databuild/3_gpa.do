/*
	Project: High School Grades 
	Data build sequence: 3/10
	Purpose: create 9th grate GPA  and HS final GPA
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
	do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
/****************************************************************************/
* 1.  9th grade GPA
* load data
	use "$rf\UDFK2014.dta", clear
	gen primyear=substr(skoleaar,6,4)
	destring primyear,replace
	keep if kltrin=="09"
* collapse
	collapse (mean) child_gpa9=grundskolekarakter (min) skala, by(pnr  primyear) fast
	rename skala gpa9scale
* keep first year
	sort pnr primyear
	by pnr : keep if _n==1
* percentile
	sort primyear gpa9scale
	by primyear gpa9scale: egen m=mean(child_gpa9)
	by primyear gpa9scale: egen sd=sd(child_gpa9)
	gen child_std_gpa9=(child_gpa9-m)/sd
	keep pnr  child_std_gpa9 child_gpa9
* save
	compress
	save "$tf\udfk.dta",replace

/****************************************************************************/
* 2. HS GPA
*gpa in high school
	use "$rf\UDG2013.dta",clear
	rename skala gpascale
	rename KARAKTER_UDD child_hsgpa
	replace child_hsgpa=child_hsgpa/10
	gen year=year(KARAK)
	destring audd, replace
	rename audd udd
	keep pnr child_hsgpa udd year
	rename year grades_year
	save "$tf\gpa.dta",replace
