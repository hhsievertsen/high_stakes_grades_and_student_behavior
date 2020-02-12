/*
	Project: High School Grades 
	Purpose:  create Table 3 - summary stats
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc
do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"
* load data
use "$tf\analysisdata.dta",clear
* create treatment variable by re
qui: include  "x:\Data\workdata\704998\HighStakesGrades\dofiles\locals.do"
reg grades_pregrades_transf_std  `model' `covars'  i.grades_school
predict res,res 
label var  res "Recoding Residual"

/* set missings to missing*/
replace parents_income=. if parents_incomeobs==0
replace parents_schooling=. if parents_eduobs==0
label var grades_ntretten "Grades recoded"
label var grades_nsyv "Grades given after recoding"


* descriptives
	cap file close myfile
	file open myfile using "$df\tab_descriptives.tex",replace write
	foreach l in  child_age child_female child_nonwestern child_std_gpa9 parents_schooling parents_income    grades_ntretten grades_nsyv res  {
		qui: sum `l'
		local s1 : disp %3.2f r(mean)
		local s2 : disp %3.2f r(sd)
		foreach p in 10 50 90{
			egen p=DSTpctile(`l'),p(`p')
			qui: sum p
			local p`p': disp %3.2f r(mean)
			drop p
		}		
		local lab: var label `l'
	file write myfile "`lab'&`s1'&`s2'&`p10'&`p50'&`p90'\\"_n
	}
	file close myfile
