#!usr/bin/perl

##################################
# errorCheck.pl
# 
# Summary
# This perl script accepts a file as an argument and checks it for valid and invalid lines.
# Invalid lines do not contain 7 tab seperated columns, or integers that are greater than
# 32-bit. Also, a hash of distinct values for the 2nd column of valid lines is maintained
# and output.
#
# Usage
# errorCheck.pl <inputFile>
#
# Input
# inputFile
#
# Output
# inputFileCLEAN - All valid lines
# inputFileRESULTS - Statistics of program execution
#
# Author
# Jason Laver - Jason.Laver@gmail.com
#
#
# Notes
# Since there are entries with 7 columns that are either tab or space seperated,
# split on all whitespace instead and then pretty print with commas.
#
##################################


#DEVMODE displays prints for dev purposes 1:error lines only, 2:all output
$DEVMODE = 1;

if ($#ARGV != 0) {
print "ERROR: Usage errorCheck.pl <Data File>\n";
exit 1;
}

###################################
#Initialize our variables and open our files
###################################
#Original data file
$dataFileName = $ARGV[0];
open DATAFILE, "<".$dataFileName or die "ERROR: Cannot open $dataFileName";

#Data file containing clean data
$dataFileCleanName = $dataFileName."CLEAN";
open DATAFILECLEAN, ">".$dataFileCleanName or die "ERROR: Cannot open $dataFileCleanName";

#Results file to display statistics of error check
$resultsFileName = $dataFileName."RESULTS";
open RESULTSFILE, ">".$resultsFileName or die "ERROR: Cannot open $resultsFileName";

#Statistics variables
$parsedLines = 0;
$errorLinesColumn = 0;
$errorLinesThirtyTwo = 0;
%columnTwoDistinct;

if ($DEVMODE == 2) {print "Beginning Error Check on file: $dataFileName\n";}

###################################
# Begin parsing of input file
###################################
while (<DATAFILE>) {
	$errorFlag = 0;
	#Increase counter for lines counted
	$parsedLines++;
	chomp $_;
	
	#Split line on all whitespace
	@myColumns = split(/\s/);

	#Check for 7 columns from split on tab
	#print "@myColumns : $myColumns\n";
	if (@myColumns != 7) {
		$errorFlag = 1;
		$errorLinesColumn++;
		if ($DEVMODE >= 1) {print "BAD LINE - Columns != 7: $_\n";}
	}
	
	#Check each item for 32-bit and NOT NULL and 
	#32bit 0 - 4294967295
	$currColumnIndex = 0;
	if ($errorFlag == 0) {
		foreach $currColumn (@myColumns) {
			if (($currColumn >= 0) && ($currColumn <= 4294967295) && ($currColumn =~ /^\d+$/)) {
				if ($DEVMODE == 2) {print "GOOD DATUM - 32-bit: $currColumn\n";}
			} else {
				if ($DEVMODE >= 1) {print "BAD LINE - 32-bit: $_\n";}
				$errorFlag = 1;
				$errorLinesThirtyTwo++;
			}
		}
	}
	
	
	#If ok, write to DATAFILECLEAN and check column 2 distinctness
	if ($errorFlag == 0) {
		if ($DEVMODE == 2) {print "GOOD LINE: $_\n"}
		#Write to DATAFILECLEAN
		$prettyPrint = "";
		foreach $currColumn (@myColumns) {
			$prettyPrint = $prettyPrint."$currColumn,";
		}
		chop($prettyPrint);
		$prettyPrint = $prettyPrint."\n";
		print DATAFILECLEAN "$prettyPrint";
		
		#Check distinctness of 2nd Column
		if ( exists $columnTwoDistinct{@myColumns[1]} ){
			if ($DEVMODE == 2) {print "COLUMN EXISTS : @myColumns[1]\n"}
			#Increment items occurence count
			$columnTwoDistinct{"@myColumns[1]"}++;
		} else {
			if ($DEVMODE == 2) {print "NEW COLUMN VALUE: @myColumns[1]\n";}
			#Add entry to hash and set its occurences to 1
			$columnTwoDistinct{"@myColumns[1]"} = 1;
		}
	}
	
}

###################################
# Output all of our statistics
###################################
print RESULTSFILE "Results for check of $dataFileName\n";
print RESULTSFILE "\tLines Parsed: $parsedLines\n";
print RESULTSFILE "\tLines with Errors: ".($errorLinesColumn+$errorLinesThirtyTwo)."\n";
print RESULTSFILE "\tLines with Errors - 7 Column: $errorLinesColumn\n";
print RESULTSFILE "\tLines with Errors - 32 Bit: $errorLinesThirtyTwo\n";
print RESULTSFILE "Number of distinct 2nd column values: ".keys(%columnTwoDistinct)."\n";

if ($DEVMODE == 2) {
	foreach $currKey (keys %columnTwoDistinct) {
		print "Item: $currKey - Occurences: $columnTwoDistinct{$currKey}\n";
	}
}

#Close all files
close DATAFILE;
close DATAFILECLEAN;
close RESULTSFILE;