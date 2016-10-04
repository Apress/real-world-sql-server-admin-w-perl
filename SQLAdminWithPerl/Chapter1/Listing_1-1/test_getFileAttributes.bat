@echo off
rem Run this in the current directory where 
rem both getFileAttributes.pl and test.txt 
rem reside. File test.txt can be any file. 
rem Its content is not important.

perl getFileAttributes.pl test.txt > getFileAttributes.log
