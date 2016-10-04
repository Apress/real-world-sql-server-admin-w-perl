@echo off
rem This batch file runs the Perl script BCPFileCompare.pl
rem to comapre the files in the two specified sub-directories.
rem The -t option is included to tell the script to perform
rem the text comparison.

rem Make sure that the two sub-directories exist and have the 
rem files for comparison.

perl BCPFileCompare.pl -i.\BCPin -o.\BCPout1 -t
