@echo off
rem This batch file illustrates how to run the Perl script
rem accessSQL_SQLDMO.pl, which accepts a server name for the
rem default SQL Server instance or a server name followed 
rem with an instance name for a named SQL Server instance on
rem the command line and invokes SQLDMO to retrieve 
rem the SQL Server information.

perl accessSQL_SQLDMO.pl %1
