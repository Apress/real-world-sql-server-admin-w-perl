@echo off
rem This batch file runs the sortSPFiles.pl script against the
rem directory .\test where T-SQL scripts, that define stored procedures,
rem are placed.

perl sortSPFiles.pl -d pubs -f .\test\*.*
