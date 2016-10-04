@echo off
rem This batch file runs the Perl script compareColumns.pl

echo --
echo The servers, databases, and tables are all hard coded in the Perl 
echo script for demo purposes.
echo It assumes that the local machine has two SQL2000 instances: APOLLO
echo and PANTHEON. To run the script in your own environment, modify
echo the script to include the correct instance names.
echo --

perl compareColumns.pl
