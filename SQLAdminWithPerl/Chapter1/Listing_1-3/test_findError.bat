@echo off
rem Run this in the current directory where 
rem both findError.pl and errorlog.txt 
rem reside. File errorlog.txt should be a 
rem typical SQL Server errorlog.  

perl findError.pl errorlog.txt > findError.log
