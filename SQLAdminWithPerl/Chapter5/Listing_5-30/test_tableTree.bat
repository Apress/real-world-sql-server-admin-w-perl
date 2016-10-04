@echo off
rem This batch file runs the script tableTree.pl to produce a 
rem reference tree for the table pubs.dbo.titleauthor in the 
rem named instance APOLLO on the local server.

perl tableTree.pl -S .\APOLLO -D pubs -T dbo.titleauthor