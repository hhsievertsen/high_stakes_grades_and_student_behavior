/*
	Project: High School Grades 
	Data build sequence: 4/10
	Purpose: child covariates and parent ids
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* loop over calendar years (variables are fixed over time, by assumption)
	forval i=2003/2012{
		use "$rf\GRUND`i'.dta", clear
		if `i'>2006{
			rename FOED_DAG foed_dag
		}
		keep pnr IELANDG2 IE_TYPE koen foed_dag far_id mor_id
		gen byte nonwestern=IELANDG2=="3"   /* Origin*/
		gen byte female=koen==2				/* Gender*/
		rename foed_dag dateofbirth			/* Date of Birth */
		rename far_id father_id				/* Father id */
		rename mor_id mother_id				/* Mother id */
		keep pnr nonwestern  fem* dateofbirth father_id mother_id
		label var nonwestern 		"Non-western origin"
		label var female 			"Girl"
		label var dateofbirth 		"Date of birth"
		save "$tf\childdata`i'.dta",replace
	}
* Append and save
	use "$tf\childdata2003.dta"
	forval i=2004/2012{
		append using "$tf\childdata`i'.dta"
	}
* Keep one obs per child
	bys pnr: keep if _n==1
	compress
save "$tf\childdata.dta",replace
