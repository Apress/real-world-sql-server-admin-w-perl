# This script calls the function dbaParseQDON() to take apart 
# a T-SQL qualified object name.
# This script includes the definition of the function
# dbaParseQDON(). It's also defined in the module
# SQLDBA::ParseSQL. 

# You can uncomment the following line to import the
# function from the module SQLDBA::ParseQDON.
#use SQLDBA::ParseSQL 'dbaParseQDON';

use strict;
use Data::Dumper;

my $name = 'pubs."dbo".[qeire[[[ """sd]][]]fda]';  # a sample name for test only
print Dumper(dbaParseQDON($name));                 # parse the sample name


######################
sub dbaParseQDON {
   my $name = shift or die "***Err: dbaParseQDON() expects a string.";
   my $obj = q/  [\w@\#]+                  # a regular identifier
                | \" (?: [^\"]|\"\")+ \"   # a delimited identifier with double quotes
                | \[ (?: [^\]]|\]\])+ \]   # a delimited identifier with square brackets
              /;
   my $re = qr{   ($obj)\.($obj)?\.($obj)  # a database-name qualified object name
                | (?:($obj)\.)?($obj)      # a owner qualified object name
             }ix;
   my $ref;
   if ($name =~ /^\s*$re\s*$/ix) {
      $ref = {
         db => $1,
         owner => (defined $2 ? $2 : $4),
         obj => (defined $3 ? $3 : $5)
      };
   }
   return $ref;
} # dbaParseQDON
