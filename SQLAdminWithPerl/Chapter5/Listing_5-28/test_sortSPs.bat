@ech off
rem This batch file runs the sortSPs.pl script on the T-SQL script file 
rem someSPs.sql and sort the stored procedures defined in the T-SQL
rem script file.

rem The default database is the pubs database, and the sorting
rem is case sensitive.

perl sortSPs.pl -d pubs -f someSPs.sql -c
