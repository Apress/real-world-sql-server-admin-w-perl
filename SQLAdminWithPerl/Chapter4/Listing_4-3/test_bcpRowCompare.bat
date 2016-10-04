@echo off
rem This batch file runs the Perl script BCPRowCompare.pl
rem to compare the number of rows copied in the log file 
rem from the bulk copy in with the number of rows copied in 
rem the log file from the bilk copy out.

perl BCPRowCompare.pl -i bcpIn.log -o bcpOut.log
