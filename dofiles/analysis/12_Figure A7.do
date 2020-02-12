/*
	Project: High School Grades 
	Purpose:  create Figure A7
	Last edited: Aug 2019, by Hans H. Sievertsen/h.h.sievertsen@bristol.ac.uk
*/
* load globals etc

do "X:\Data\Workdata\704998\HighStakesGrades\dofiles\settings.do"	
/*****************************************************************************/
* a
* Distribution of grades in first year
* load high school data
	use "$rf\UDGK2015.dta", clear
	destring bevisaar, replace
	keep if bevisaar>2004
* drop degrees:  HF, Studenterkursus, IB, Fransk , 2-år HHX,  1-år HHX, Værksted, Flygtningekursus Adgangskurus, IB, Ingeniørkurus
	drop if inlist(udd,1539,1652,1879,1889,1891,1895,4007,4031,4008,5045,5126,5230,1899,5299)
* drop variables that are redundant
	drop coesa cprtjek cprtype STUDYPROGRAM1_LEVEL STUDYPROGRAM1_SUBJECTCODE STUDYPROGRAM1_SUBJECTNAME STUDYPROGRAM2_LEVEL STUDYPROGRAM2_SUBJECTCODE STUDYPROGRAM2_SUBJECTNAME STUDYPROGRAM3_LEVEL STUDYPROGRAM3_SUBJECTCODE STUDYPROGRAM3_SUBJECTNAME STUDYPROGRAM4_LEVEL STUDYPROGRAM4_SUBJECTCODE STUDYPROGRAM4_SUBJECTNAME
* gen bevisaar
	destring bevisaar karafgtid, replace
	preserve
		keep if skala=="13-skala"
	* only keep first year grades
		keep if karafgtid==bevisaar-2
	* collapse
		collapse (count) n=instnr,by(karakter bevisaar) fast
		bys bevisaar: egen sum=sum(n)
		gen share=100*n/sum
	* plot
		replace karakter=karakter-0.3 if bevisaar==2005
		replace karakter=karakter-0.1 if bevisaar==2006
		replace karakter=karakter+0.1 if bevisaar==2007
		replace karakter=karakter+0.3 if bevisaar==2008
		tw 	(bar share karakter if bevisaar==2005, barwidth(0.2) lcolor(gs4) fcolor(gs4)) ///
			(bar share karakter if bevisaar==2006, barwidth(0.2) lcolor(gs7) fcolor(gs7)) ///
			(bar share karakter if bevisaar==2007, barwidth(0.2) lcolor(gs10) fcolor(gs10)) ///
			(bar share karakter if bevisaar==2008, barwidth(0.2) lcolor(gs13) fcolor(gs13) ) ///
		   ,legend(order(1 "2005 cohort" 2 "2006 cohort" 3 "2007 cohort" 4 "2008 cohort") region(lcolor(white))) ///
		   graphregion(lcolor(white) fcolor(white)) ytitle("Share (percent)") ///
			xlabel(0 "0" 3 "03" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10" 11 "11" 13 "13") ///
			xtitle("Grade")  plotregion(lcolor(black) fcolor(white))
			graph export "$df\fig_hist_of_grading_pattern.pdf",replace
	restore 
/****************************************************************************/ 
* b *
* Transformed grades
	use "$rf\UDGK2015.dta", clear
	destring bevisaar, replace
	keep if bevisaar>2004
* drop degrees:  HF, Studenterkursus, IB, Fransk , 2-æ² HHX,  1-æ² HHX, Vç³«sted, Flygtningekursus Adgangskurus, IB, Ingenið²«µrus
	drop if inlist(udd,1539,1652,1879,1889,1891,1895,4007,4031,4008,5045,5126,5230,1899,5299)
* drop variables that are redundant
	drop coesa cprtjek cprtype STUDYPROGRAM1_LEVEL STUDYPROGRAM1_SUBJECTCODE STUDYPROGRAM1_SUBJECTNAME STUDYPROGRAM2_LEVEL STUDYPROGRAM2_SUBJECTCODE STUDYPROGRAM2_SUBJECTNAME STUDYPROGRAM3_LEVEL STUDYPROGRAM3_SUBJECTCODE STUDYPROGRAM3_SUBJECTNAME STUDYPROGRAM4_LEVEL STUDYPROGRAM4_SUBJECTCODE STUDYPROGRAM4_SUBJECTNAME
* gen bevisaar
	destring bevisaar karafgtid, replace
	*preserve
		* only keep first year grades
		keep if karafgtid==bevisaar-2
		
		drop if skala=="7-trinsskala" & bevisaar<2009
		drop if skala=="13-skala" & bevisaar>2008

	* Transform grades
		gen int t=.
		replace t=-3 if karakter==0 &  skala=="13-skala" & bevisaar<2009
		replace t=0 if inlist(karakter,3,5) &  skala=="13-skala" & bevisaar<2009
		replace t=2 if inlist(karakter,6) &  skala=="13-skala" & bevisaar<2009
		replace t=4 if inlist(karakter,7) &  skala=="13-skala" & bevisaar<2009
		replace t=7 if inlist(karakter,8,9) &  skala=="13-skala" & bevisaar<2009
		replace t=10 if inlist(karakter,10) &  skala=="13-skala" & bevisaar<2009
		replace t=12 if inlist(karakter,11,13) &  skala=="13-skala" & bevisaar<2009
		
		replace t=karakter if   bevisaar>2008
		drop karakter
		rename t karakter
	* collapse
		collapse (count) n=instnr,by(karakter bevisaar)
		bys bevisaar: egen sum=sum(n)
		gen share=100*n/sum
	* plot
		replace karakter=karakter-0.36 if bevisaar==2005
		replace karakter=karakter-0.18 if bevisaar==2006
		replace karakter=karakter+0.18 if bevisaar==2008
		replace karakter=karakter+0.36 if bevisaar==2009
		replace karakter=karakter+0.54 if bevisaar==2010
		replace karakter=karakter+0.72 if bevisaar==2011
			tw 	(bar share karakter if bevisaar==2005, barwidth(0.18) lcolor(gs8) fcolor(gs4)) ///
				(bar share karakter if bevisaar==2006, barwidth(0.18) lcolor(gs10) fcolor(gs7)) ///
				(bar share karakter if bevisaar==2007, barwidth(0.18) lcolor(gs12) fcolor(gs10)) ///
				(bar share karakter if bevisaar==2008, barwidth(0.18) lcolor(gs14) fcolor(gs13) ) ///
				(bar share karakter if bevisaar==2009, barwidth(0.18) lcolor(black) fcolor(black) ) ///
				(bar share karakter if bevisaar==2010, barwidth(0.18) lcolor(gs4) fcolor(gs4) ) ///
				(bar share karakter if bevisaar==2011, barwidth(0.18) lcolor(gs6) fcolor(gs6) ) ///
				(bar share karakter if bevisaar==2, barwidth(0.18) lcolor(white) fcolor(white) ) ///
			   ,legend(rows(3) order(1 "2005 cohort" 2 "2006 cohort" 3 "2007 cohort" 4 "2008 cohort" 5 "2009 cohort" 6 "2010 cohort"  7 "2011 cohort") region(lcolor(white))) ///
			   graphregion(lcolor(white) fcolor(white)) ytitle("Share (percent)") ///
				xlabel(-3 "-3" 0 "0" 2 "2" 4 "4" 7 "7"  10 "10" 12 "12") ///
				xtitle("Grade")  plotregion(lcolor(black) fcolor(white))
				graph export "$df\fig_hist_of_grading_pattern_transformed.pdf",replace
	restore
