# This script shows how to scan the BCP output file for
# error messages.

# Finding the error messages is the easy part. Finding the object 
# names and associating them with the error messages is the more
# difficult part.

use strict;
my $bcpLog = shift or die "***Err: $0 expects a file name.";

scanBCPError($bcpLog);

####################
sub scanBCPError {
   my $bcpLog = shift or die "***Err: scanBCPError() expects a file name.";
   
   my $dbName  = q/(?:[\w@#]+ | \"(?:[^"]|\\\")+\")/;
   my $objName = q/(?:[\w@#]+ | \"(?:[^"]|\\\")+\" | \[(?:[^]]|\]\])+\])/;
   my $re = qr{
               (?:         # all in double quotation marks
                  \"(?:[^"]|\\\"|\"\")+\"      
                 |          # one-part name with owner omitted
                  $objName
                 |          # two-part name with owner omitted
                  $objName\.$objName
                 |          # three-part name with owner omitted
                  $dbName\.\.$objName
                 |          # three-part name
                  $dbName\.$objName\.$objName
               )
          }ix;
       
   open(BCPLOG, $bcpLog) or die "***Err: couldn't open $bcpLog for read.";
   while (<BCPLOG>) {
      # parse the bcp command line for table/view/query
      if (/\>\s*bcp(\.exe)?\s+($re)\s+(in|out|queryout)/i) {
         print "\nBCP $3 $2\n";
         next;
      }

      # check for parameter validation error
      if (/(usage:\s+bcp|Unknown argument)/i) {
         print "\t***Parameter validation error.\n";
         next;
      }
      # check for SQL Server error error
      if (/\[Microsoft\]\[ODBC SQL Server Driver\]\[SQL Server\](.+)/i) {
         print "\t***$1\n";
         next;
      }
      # check for ODBC driver error error
      if (/\[Microsoft\]\[ODBC SQL Server Driver\](.+)/i) {
         print "\t***$1\n";
         next;
      }
   }
   close(BCPLOG);
} # scanBCPError