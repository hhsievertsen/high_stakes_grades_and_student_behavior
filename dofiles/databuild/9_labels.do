/*
	Project: High School Grades 
	Data build sequence: 9/10
	Purpose:  labels and cleaning
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* load data
use "$tf\rawdata.dta",clear
* child variables
	gen child_gpa9m = child_gpa9==.
	replace child_gpa9=0 if child_gpa9==.
	gen grades_pregradesround=round(grades_pregrades,.1)
* generate one parental income variable
	gen parents_incomeobs=0+(father_inc!=.) +(mother_inc!=.) 
	replace mother_inc=0 if mother_inc==.
	replace father_inc=0 if father_inc==.
	gen parents_income=(father_inc+mother_inc)/parents_incomeobs
	replace parents_income=0 if parents_incomeobs==0
* generate one parental education variable
	gen parents_eduobs=0+(father_schooling!=.) +(mother_schooling!=.) 
	replace mother_schooling=0 if mother_schooling==.
	replace father_schooling=0 if father_schooling==. 
	gen parents_schooling=(mother_schooling+father_schooling)/parents_eduobs
	replace parents_schooling=0 if parents_eduobs==0
	drop father* mother* child_dateofbirth 
	gen oneparenteduobs=parents_eduobs==1
	gen twoparenteduobs=parents_eduobs==2
	gen oneparentincobs=parents_incomeobs==1
	gen twoparentincobs=parents_incomeobs==2
* new variables
	gen grades_academic=grades_udd==1199
	gen grades_mnscale=grades_nsyv
	replace grades_mnscale=grades_ntretten if grades_ntretten<grades_nsyv
	drop grades_udd
	rename grades_pregradestransformed grades_pregrades_transf
* labels
	label var child_gpa9m 							"Missing 9th grade GPA"
	forval i=1/6{
		label var child_enrolled_`i'_any "Enrolled in education within `i'y"
		label var child_enrolled_`i'_uni "Enrolled in university within `i'y"
		label var child_graduated_`i'_any "Graduated with another degree within `i'y"
		label var child_graduated_`i'_uni "Graduated with a university degree within `i'y"	
	}
	label var parents_eduobs 						"Number of parents with non-missing schooling"
	label var parents_schooling 					"Parents' years of schooling"
	label var parents_income 						"Parents' income (1,000 Euro)"
	label var oneparenteduobs 						"One parent's education observed"
	label var twoparenteduobs 						"Both parents' education observed"
	label var oneparentincobs 						"One parent's income observed"
	label var twoparentincobs						"Both parents' income observed"
	label var child_id 								"Child identifier"
	label var child_std_gpa9						"9th grade GPA"
	label var child_dropoutyear						"Dropout year, (0=no dropout)"
	label var child_age								"Age at HS enrollment"
	label var child_female 							"Female"
	label var child_2ndyear_laborinc  				"Labour income in second year, (2015 1,000 Euro)"
	label var child_2ndyear_work  					"Worked in second year"
	label var grades_alevels 						"Number of A-levels"
	label var grades_academic 						"Academic high school"
	label var grades_nsyv 							"Number of grades on 7 point scale"
	label var grades_ntretten 						"Number of grades on 13-scale"
	label var grades_mnscale 						"Lowest number of grades on both scales"
	label var grades_postgrades 					"GPA after transformation"
	label var grades_postgrades_ext 				"GPA after transformation,ext"
	label var grades_postgrades_int					"GPA after transformation,int"
	label var grades_pregrades 						"GPA before transformation"
	label var grades_pregrades_transf	 			"GPA of grades given before, transformed"
	label var grades_placebo 						"Indicator for placebo cohort"
	label var selection_dropouts 					"Dropout"
* save
	
save "$tf\rawanalysisdata.dta",replace

