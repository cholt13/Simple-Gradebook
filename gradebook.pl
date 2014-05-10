#!/usr/bin/perl -w

# Corey Holt - cmh09h
# COP4342
# 11/5/2013
# Assignment 10

# This Perl script uses filehandles to read data from three text files:
# students.txt, items.txt, and scores.txt. It uses the data from these
# files to generate an output file containing a table of student names,
# student ids, grading item names and scores for each student, averages
# for each student, and also averages for each grading item as well as
# an overall average across all students.

# Declare that the strict pragma will be used (all variables should
#  be declared and strings should be quoted)
use strict;

# Check for improper use of command line arguments
if (@ARGV != 0)
{
	# Print error message and exit with error status
	print "Script usage: gradebook.pl\n";
	exit 1;
}

# Try to open the three input files: students.txt, items.txt, scores.txt
if (!open IN1, "<students.txt")
{
	die "Could not open students.txt";
}
if (!open IN2, "<items.txt")
{
	die "Could not open items.txt";
}
if (!open IN3, "<scores.txt")
{
	die "Could not open scores.txt";
}

# Try to open the output file report.txt
if (!open OUT, ">report.txt")
{
	die "Could not open report.txt for output";
}

# Need a variable to store lines read from the files
my $line;

# Need a hash to store student names and their corresponding ids
my %student_hash;
# Need an array to hold the split portions of each line from the
#  students.txt file
my @sinfo;
# Variable to store student name
my $sname;
# Variable to store student id
my $sid;
# Keep track of the longest student name in the file for print
#  formatting later
my $maxlength = 0;

# Loop through all of the lines in students.txt using the filehandle
while ($line = <IN1>)
{
	# Get rid of the newline char at the end of the line
	chomp($line);
	# Split the line into student name and student id using the :
	#  as the separator
	@sinfo = split / *: */, $line;
	# Store the student name
	$sname = $sinfo[0];
	# Check if the name has the new longest length and store if does
	if ((length $sname) > $maxlength)
	{
		$maxlength = length $sname;
	}
	# Store the student id
	$sid = $sinfo[1];
	# Create new hash entry using name as key and id as value
	$student_hash{$sname} = $sid;
}
# Finished reading from students.txt, so close IN1
close IN1;

# Need a hash to store the item types and their associated weights
my %item_weights;
# Need an array to hold the split portions of the line from items.txt
my @item_info;
# Need to maintain an array of the item names in original order, because
#  the hash loses the original ordering
my @items;
# Variable to hold the item name
my $item;
# Variable to hold the item weight
my $item_weight;
# Variable to hold total item weight
my $total_weight;

# Loop through all of the lines in items.txt using the filehandle
while ($line = <IN2>)
{
	# Remove the newline from the end of the line
	chomp($line);
	# Split the line into the item name and the item weight using
	#  whitespace as the separator
	@item_info = split /\s+/, $line;
	# Store the item name
	$item = $item_info[0];
	# Store the item weight
	$item_weight = $item_info[1];
	# Keep running total of item weights
	$total_weight += $item_weight;
	# Maintain the list of items in original order
	push @items, $item;
	# Create a new hash entry using the item as key and weight as value
	$item_weights{$item} = $item_weight;
}
# Finished reading from items.txt, so close IN2
close IN2;

# Check if the total item weights is not 100
if ($total_weight != 100)
{
	die "Error: Item weights do not add up to 100";
}

# Need a hash to store the student id and a hash of that student's scores
#  for each of the items
my %scores_hash;
# Need an array to hold the split portions of the line from scores.txt
my @score_info;
# Variable to store the score
my $score;

# Loop through all of the lines in scores.txt using the filehandle
while ($line = <IN3>)
{
	# Remove the newline char from the line
	chomp($line);
	# Split the line according to whitespace and store the parts
	@score_info = split /\s+/, $line;
	# Store the student id
	$sid = $score_info[0];
	# Store the item name
	$item = $score_info[1];
	# Store the score value
	$score = $score_info[2];
	# Create a new hash entry consisting of the student id as the key
	#  and another hash as the value. The nested hash uses the item
	#  name as its key and the score as the value
	$scores_hash{$sid}{$item} = $score;
}
# Finished reading from scores.txt, so close IN3
close IN3;

# Print the Name and StuID column headers to the report.txt file
printf OUT "%-${maxlength}s %5s", "Name", "StuID ";
# Print the item names as column headers to the file
foreach (@items)
{
	printf OUT "%5s ", $_;
}
# Print the average column header to the file
printf OUT "%7s", "average\n";

# Call the print_separators subroutine to print the '-' char line
#  separator to the report.txt file
&print_separators;

# Create an array that holds the student names sorted alphabetically
my @sorted_names = sort (keys %student_hash);
# Prepare a variable for calculating individual student averages
my $indiv_avg = 0.0;
# Prepare an array to hold every student's average for a later
#  overall average calculation
my @averages;
# Loop through each student by name in alphabetic order
foreach $sname (@sorted_names)
{
	# Print the student's name to the file
	printf OUT "%-${maxlength}s ", $sname;
	# Get the student's id from %student_hash
	$sid = $student_hash{$sname};
	# Print the student's id to the file
	printf OUT "%5d ", $sid;
	# Loop through each item in the items array (is sorted according
	#  to the original ordering of the items in items.txt)
	foreach $item (@items)
	{
		# Check to see if the current student has a score for
		#  the current item
		if (exists $scores_hash{$sid}{$item})
		{
			# Score exists, so print it to the file
			printf OUT "%5d ", $scores_hash{$sid}{$item};
		}
		else
		{
			# Score doesn't exist, so create an entry for
			#  it with the value 0 for average calculations
			$scores_hash{$sid}{$item} = 0;
			# Print a blank for that table cell in the file
			printf OUT "%5s ", "";
		}
		# Add the score multiplied by the item's associated weight
		#  out of 100 to the student's average
		$indiv_avg += ($scores_hash{$sid}{$item} *
			       ($item_weights{$item} / 100));
	}
	# Have calculated the student's average grade by looking at their
	#  grades for each individual item, so print the student's overall
	#  average to the file in the last column
	printf OUT "%7.2f", $indiv_avg;
	# Push the student's average to the averages array to be used
	#  later in the overall average calculation across all students
	push @averages, $indiv_avg;
	# Reset the indiv_avg variable to 0 for the next student
	$indiv_avg = 0.0;
	# Go to the next line of the output file for the next student
	print OUT "\n";
}

# Call the print_separators subroutine again to enclose the table
&print_separators;

# Print the 'average' row label to the file
printf OUT "%-${maxlength}s ", "average";
# Print a blank for the StuID column
printf OUT "%5s ", "";

# Variable to store individual item averages across all students
my $item_avg = 0.0;
# Use student ids to get the appropriate scores for a given item
my @sids = keys %scores_hash;
# Loop through each item type
foreach $item (@items)
{
	# Look at each student by id
	foreach $sid (@sids)
	{
		# Add all of the grades for the current item together
		$item_avg += $scores_hash{$sid}{$item};
	}
	# Divide by the number of students to get the average
	$item_avg = $item_avg / @sids;
	# Print the average for the current item to the file
	printf OUT "%5d ", $item_avg;
	# Reset the item_avg variable for the next item
	$item_avg = 0.0;
}

# Variable for the overall average of all of the students' averages
my $overall_avg = 0.0;
# Loop through each individual average in the averages array
foreach $indiv_avg (@averages)
{
	# Add the individual average to the overall average variable
	$overall_avg += $indiv_avg;
}
# Divide the overall avg by the number of averages (# students) to get
#  the actual overall average across all students
$overall_avg = $overall_avg / @averages;

# Print the overall average to the file
printf OUT "%7.2f\n", $overall_avg;

# Need this subroutine for printing table line separators
sub print_separators
{
	# Loop counter variable
	my $i;
	# Print enough dashes to cover the length of the longest
	#  student name
	for ($i = 0; $i < $maxlength; ++$i)
	{
		print OUT "-";
	}
	# Print five dashes for the StuID column
	print OUT " ----- ";
	# Each item has five dashes as its separator, so print enough
	#  sets of five dashes for all of the items
	for ($i = 0; $i < @items; ++$i)
	{
		print OUT "----- ";
	}
	# Print seven dashes for the average column separator
	print OUT "-------\n";
}

# Finished writing to report.txt, so close OUT
close OUT;

# Exit the perl script successfully
exit 0;
