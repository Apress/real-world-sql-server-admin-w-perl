@echo off
rem This batch file illustrates how to run the Perl
rem script getSQLStartupParams.pl. The Perl script
rem expects two command line parameters, a server
rem followed by a named instance name.

perl getSQLStartupParams.pl %1 %2
