@echo off
rem This batch file runs the Perl script compareDBs.pl to
rem compare the two pubs databases in the two named instances
rem on the local server.
rem
rem You may need to change the server names and database names 
rem to test/use the script in your own environment.

perl compareDBs.pl -S.\apollo -D pubs -s.\pantheon -d pubs -c
