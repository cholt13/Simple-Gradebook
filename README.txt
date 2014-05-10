Author: Corey Holt
Date: 11/5/2013

This Perl script implements a simple, plain text gradebook.

The script reads from three text files that should be named 
students.txt, items.txt and scores.txt. It uses the data from these
files to generate an output file named report.txt that contains a
table of student names, student ids, grading item names and scores
for each student, averages for each student, and also averages for 
each grading item as well as an overall average across all students.

Format for the students.txt file:

<student_name> : <student_id>


Format for the items.txt file:

<item_name>	<percentage_of_total_grade>


Format for the scores.txt file:

<student_id> <item_name> <score>
