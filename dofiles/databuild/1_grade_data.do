/*
	Project: High School Grades 
	Data build sequence: 1/10
	What this file does: extract grading data from grade records
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
	Notes:
		- 0.009% of obs are deleted because grading scale is wrong
		- 0.002% of obs are deleted because the individual already graduated with the same degree/
*/
* load globals etc
	do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* load high school data
	use "$rf\UDGK2015.dta", clear
* drop degrees:  Only keep STX type degrees
	drop if inlist(udd,1539,1652,1879,1889,1891,1895,4007,4031,4008,5045,5126,5230,1899,5299)
* drop variables that are not used
	drop coesa cprtjek cprtype STUDYPROGRAM1_LEVEL STUDYPROGRAM1_SUBJECTCODE STUDYPROGRAM1_SUBJECTNAME STUDYPROGRAM2_LEVEL STUDYPROGRAM2_SUBJECTCODE STUDYPROGRAM2_SUBJECTNAME STUDYPROGRAM3_LEVEL STUDYPROGRAM3_SUBJECTCODE STUDYPROGRAM3_SUBJECTNAME STUDYPROGRAM4_LEVEL STUDYPROGRAM4_SUBJECTCODE STUDYPROGRAM4_SUBJECTNAME
* create variables for year of graduation and year of exam
	destring bevisaar, gen(year)
	destring karafgtid, replace
* only keep those who graduated after 2004
	keep if year>2004
* grading scale	
	gen byte  syvskala=skala=="7-trinsskala"
* drop if applied grading scale is wrong (less than 0.009% percent of the observations)
	drop if syvskala==1 & year<2008
* placebo reform:  transform grades from the students in earlier cohorts
	replace syvskala=1 if year==2007 & karafgtid>2005
	replace syvskala=1 if year==2006 & karafgtid>2004
	replace syvskala=1 if year==2005 & karafgtid>2003
* number of grades on each scale
	gen byte tretten=syvskala==0
	gen byte syv=syvskala==1
* calculate gpas by scale
	gen grades_high=syvskala==1&karakter>9
	gen grades_passed=syvskala==1&karakter>2
	gen yearto=year-karafgtid
	gen karB=karakter 								if syvskala==1 & niveau=="B"
	gen karA=karakter 								if syvskala==1 & niveau=="A"
	gen karC=karakter 								if syvskala==1 & niveau=="C"
	gen kar7=karakter 								if syvskala==1
	gen kar7ext=karakter 							if syvskala==1 & testtype=="Eksamen skriftlig"
	gen kar7int=karakter 							if syvskala==1 & testtype!="Eksamen skriftlig"
	gen kar13=karakter 								if syvskala==0
	gen kar7omr=KARAKTER_OMREGNET 					if syvskala==0
* create average by individual X graduation year X Degree
	sort pnr udd year
	by pnr udd year: egen grades_nsyv=sum(syv)						/* Grades given on the new scale */
	by pnr udd year: egen grades_ntretten=sum(tretten)				/* Grades given on the old scale */
	by pnr udd year: egen grades_postgrades=mean(kar7)				/* GPA given on the new scale */
	by pnr udd year: egen grades_postgrades_ext=mean(kar7ext)     	/* GPA given on the new scale,external */
	by pnr udd year: egen grades_postgrades_int=mean(kar7int)		/* GPA given on the new scale,internal */
	by pnr udd year: egen grades_pregrades=mean(kar13)				/* GPA given on the old scale */
	by pnr udd year: egen grades_pregradestransformed=mean(kar7omr) /* GPA given on the old scale, transformed to the new scale */
* Number of A-Levels and B levels
	bys pnr udd year GYM_FAG niveau: gen t=_n==1
	gen alevel=niveau=="A"&t==1												
	gen blevel=niveau=="B"&t==1		
	gen alevelmat=niveau=="A"&FAG_TXT=="Matematik"
	by pnr udd year: egen grades_alevel_mat=max(alevelmat)			/* Number of A level maths */
	by pnr udd year: egen grades_alevels=sum(alevel)			     /* Number of A levels  */
	by pnr udd year: egen grades_blevels=sum(blevel)			     /* Number of B levels  */
* keep what we need
	keep  pnr INSTNR_BEVIS year grades_*   udd    
	rename INSTNR_BEVIS instnr
* one obs per individual X degree X Year
	by pnr udd year: drop if _n>1
* remove the second time a person graduates with the same degree (0.02%). 
	bys pnr udd: drop if _n>1
* placebo indicator variables 
	gen grades_placebo=year<=2007
* final renaming
	rename year grades_year
	rename instnr grades_schoolid
compress
save "$tf\gradingdata.dta",replace
