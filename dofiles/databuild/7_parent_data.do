/*
	Project: High School Grades 
	Data build sequence: 7/10
	Purpose:  parental covariates
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
/****************************************************************************/
* 1. Parental income
* loop over grund data and save income and date of birth
	forval i=2003/2008{
		use "$rf\GRUND`i'.dta", clear
				if `i'>2006{
			rename FOED_DAG foed_dag
			}
		keep pnr DISPON_NY DISPON_NY foed_dag
		gen int t=`i'
		save "$tf\gr`i'.dta",replace
	}
* Append to one dataset
	use "$tf\gr2003.dta",clear
	forval i=2004/2008{
		append using "$tf\gr`i'.dta"
		}
* price adjustment to 2015 level using CPI (1000 EURO)
	gen income=DISPON_NY*(100/81.6)*.13*0.001 if t==2003
	replace income=DISPON_NY*(100/82.5)*.13*0.001 if t==2004
	replace income=DISPON_NY*(100/84.0)*.13*0.001 if t==2005
	replace income=DISPON_NY*(100/85.6)*.13*0.001 if t==2006
	replace income=DISPON_NY*(100/87.1)*.13*0.001 if t==2007
	replace income=DISPON_NY*(100/90.1)*.13*0.001 if t==2008
* rename and save 
	rename foed_dag dateofbirth
	drop DISPON_NY 
	compress
	bys pnr t: keep if _n==1
	save "$tf\parvars.dta",replace
/******************************************************************************/
* 2. Parental education
* load education register
	use "$rf\KOTRE2014.dta", clear
* only consider completed decrees
	drop if audd==9999 | audd==0
* merge with formats
	merge m:1 audd using "$formats\auddformats.dta", keep(1 3) nogen
* loop over years
	forval i=2003/2008{
		preserve
			drop if year(ELEV3_VTIL)>`i'
			collapse (max) pria, by(pnr) fast
			replace pria=pria/12
			gen t=`i'
			compress
			save "$tf\parschooling`i'.dta", replace
		restore
	}
* append
	use "$tf\parschooling2003.dta",clear
	forval i=2004/2008{
	append using "$tf\parschooling`i'.dta"
		}
	save "$tf\parschooling.dta",replace
/******************************************************************************/
* 3. Merge education and income
use "$tf\parschooling.dta",clear
bys pnr t: keep if _n==1
merge 1:1 pnr t using "$tf\parvars.dta", nogen
rename pria schooling
compress
save "$tf\parcovars.dta",replace
