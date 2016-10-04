@echo off
rem The Perl script printEpochSeconds.pl expects a date/time string.
rem The date/time string must be enclosed in a pair of double 
rem quotation marks so that the entire string is treated as a
rem single argument. Otherwise, since the command line arguments are
rem expected to be separated by space, the Perl script will see
rem multiple arguments, which is not what is expected.

perl printEpochSeconds.pl "2003/02/10 01:54:40"