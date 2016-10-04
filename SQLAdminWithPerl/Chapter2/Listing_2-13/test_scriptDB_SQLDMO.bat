@echo off
rem This batch file shows how to run the Perl script scriptDB_SQLDMO.pl
rem The output is a T-SQL script to create all the databases on an 
rem instance

perl scriptDB_SQLDMO.pl %1
