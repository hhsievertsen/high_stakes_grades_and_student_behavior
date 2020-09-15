# high_stakes_grades_and_student_behavior

This repository contains replication files for the paper: "High-Stakes Grades and Student Behavior" by Hans Henrik Sievertsen and Ulrik Hvidman (see: http://jhr.uwpress.org/content/early/2019/09/10/jhr.56.3.0718-9620R2.abstract).

## Files

The repository contains three folders:

1. **adofiles**: contains Stata .ado files that defines functions (programs) written by the authors.
2. **dofiles**: contains two folders of Stata .do files and two .do files. 
	* the file *settings.do* specifies the working directory, globals etc.
	* the file *locals.do* sets model specifications.
	* the folder *databuild* contains Stata .do files that creates the dataset used for analyses based on files from Statistics Denmark.
	* the folder *analysis* contains Stata .do files that creates all tables and figures for the manuscript.
3. **grade combinations** contains two files. 
	* *combinations.py* calculates the number of combinations that can lead to a certain GPA
	* *create_charts_in_R* creates visualizations using the results combinations.py.

