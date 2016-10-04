@echo off
rem This batch file shows how you can use the Data::Dumper 
rem module to help understand what are being captured by
rem by the Getopt::Std module from the command line.
rem By changing the specification of the command line, you
rem examine the resulting %opts hash by printing it out.
rem
rem Data::Dumper is one of the most useful modules.

echo Case 1
perl argTest.pl -o -i error.log -p output.log

echo Case 2
perl argTest.pl -o -i error.log -p

echo Case 3
perl argTest.pl -o -i error.log
