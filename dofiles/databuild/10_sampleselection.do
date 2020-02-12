/*
	Project: High School Grades 
	Data build sequence: 10/10
	Purpose:  sample selection and standardisation
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
/************************************************************************/
* Program to standardize
	cap program drop std
	program std
		bys grades_academic: egen m=mean(`1')
		bys grades_academic: egen sd=sd(`1')
		gen `1'_std=(`1'-m)/sd
		drop m sd
	end
/* Create main data */
	use "$tf\rawanalysisdata.dta",clear
	* drop placebo 
	drop if grades_placebo==1
* drop those who werent transformed and dropouts. Write text file
	cap file close myfile
	file open myfile using "$df\tab_selection.tex",replace write
	tempvar s
	local N=_N
	gen `s'=`N'
	file write myfile "All 2005 enrolees& "  %6.0fc (`s') "\\" _n
	drop if selection_dropouts==1
	drop if grades_year>2008
	replace `s'=_N-`N'
	local Nv=_N
	file write myfile "Did not graduate in 2008& "  %6.0fc (`s') "\\" _n
	drop if grades_ntretten==0 | grades_nsyv==0
	drop if child_hsgpa==.
	replace `s'=_N-`Nv'
	local Nv=_N
	file write myfile "Missing high school GPA data& "  %6.0fc (`s') "\\" _n
	drop if child_gpa9m==1
	drop if child_female==. | child_gpa9m==1
	replace `s'=_N-`Nv'
	local Nv=_N
	file write myfile "Missing child info"  %6.0fc (`s') "\\" _n
	* small schools 
	bys grades_school: gen n=_N
	drop if n<2
	drop n
	drop if parents_income==.  | parents_scho==.
	replace `s'=_N
	file write myfile "\midrule\\" _n
	file write myfile "Final sample& "  %6.0fc (`s') "\\" _n
	file close myfile
* save analysisdata
* Sample select 
	drop `s' select*
	std grades_postgrades
	std grades_pregrades
	std grades_pregrades_transf
	label var grades_pregrades_transf "Recoded GPA"
	std grades_postgrades_ext
	std grades_postgrades_int
* Relative groups
	* Education
	gen a=parents_schooling if parents_eduobs!=0
	qui: sum a,d
	gen parents_lowedu=parents_schoolin<r(p50)
	replace parents_lowedu=. if parents_eduobs==0
	* Income
	replace a=parents_income if parents_incomeobs!=0
	qui: sum a,d
	gen parents_loinc=parents_income<r(p50)
	replace parents_loinc=. if parents_incomeobs==0
	* GPA
	qui:	sum child_gpa9,d
	gen child_lowgpa=child_gpa9<r(p50)
	order child* grades*   
	label var grades_pregrades_transf_std "Recoded GPA"
	label var grades_postgrades_std "Grades given after recoding, std"
	compress
	save "$tf\analysisdata.dta",replace
/************************************************************************/
/* Create main data including those who graduated later */
	use "$tf\rawanalysisdata.dta",clear
* drop those who werent transformed and dropouts. Write text file
	drop if child_hsgpa==.
	drop if child_gpa9m==1
	drop if child_female==. | child_gpa9m==1
	drop if parents_income==.  | parents_scho==.
	drop if selection_dropouts==1
	drop if grades_placebo==1
* save analysisdata
* Sample select 
	std grades_postgrades
	std grades_pregrades
	std grades_pregrades_transf
	label var grades_pregrades_transf "Recoded GPA"
	std grades_postgrades_ext
	std grades_postgrades_int
* Relative groups
	* Education
	gen a=parents_schooling if parents_eduobs!=0
	qui: sum a,d
	gen parents_lowedu=parents_schoolin<r(p50)
	replace parents_lowedu=. if parents_eduobs==0
	* Income
	replace a=parents_income if parents_incomeobs!=0
	qui: sum a,d
	gen parents_loinc=parents_income<r(p50)
	replace parents_loinc=. if parents_incomeobs==0
	* GPA
	qui:	sum child_gpa9,d
	gen child_lowgpa=child_gpa9<r(p50)
	order child* grades*   
	label var grades_pregrades_transf_std "Recoded GPA"
	label var grades_postgrades_std "Grades given after recoding, std"
	compress
	save "$tf\analysisdata_later.dta",replace
/************************************************************************/
* Placebo cohorts
	use "$tf\rawanalysisdata.dta",clear
	drop if grades_placebo==0
	drop if grades_ntretten==0
	drop if selection_dropouts==1
	drop if child_female==. 
	drop if child_hsgpa==.
	drop if child_gpa9m==1 
	bys grades_school: gen n=_N
	drop if n<2
	drop n
	drop  select*
	forval i=2005/2007{ /* 2005 is first year with time info  on grades */
		preserve
		keep if grades_year==`i'
		* standardize
			std grades_postgrades
			std grades_pregrades
			std grades_pregrades_transf
			std grades_postgrades_ext
			std grades_postgrades_int
			label var grades_pregrades_transf_std "Recoded GPA"
		* Relative groups
			gen a=parents_schooling if parents_eduobs!=0
			qui: sum a,d
			gen parents_lowedu=parents_schoolin<r(p50)
			replace parents_lowedu=. if parents_eduobs==0
			replace a=parents_income if parents_incomeobs!=0
			qui: sum a,d
			gen parents_loinc=parents_income<r(p50)
			replace parents_loinc=. if parents_incomeobs==0
			qui:	sum child_gpa9,d
			gen child_lowgpa=child_gpa9<r(p50)
			order child* grades*   
			drop a 
			compress
			label var grades_postgrades_std "Grades given after recoding, std"
			save "$tf\analysisdataplacebo`i'.dta",replace
		restore
	}

	
