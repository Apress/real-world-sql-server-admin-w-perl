@echo off
rem This batch file demonstrates how to run the Perl script largeFiles.pl.
rem It instructs the Perl script to scan the directory d:\dba and all its
rem subdirectories for files larger than 5,000,000 bytes (5MB)

rem To run the Perl script in your environment, change the arguments
rem after -d and -s accordingly

perl largeFiles.pl -d D:\dba -s 5000000
