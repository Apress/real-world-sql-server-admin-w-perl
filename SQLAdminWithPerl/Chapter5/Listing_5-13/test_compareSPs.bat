@echo off
rem This batch file runs the script compareSPs.pl to compare 
rem the pubs.dbo.byroylty stored procedure on the SQL instance
rem .\apollo with that on the instance .\pntheon

perl compareSPs.pl -S.\apollo -Dpubs -Pdbo.byroyalty -s.\pantheon -d pubs -p dbo.byroyalty