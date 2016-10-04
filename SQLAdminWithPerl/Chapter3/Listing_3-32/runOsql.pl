# This script shows how to execute a SQL script
# using the function dbaRunOsql(). This function
# is impoprted from the module SQLDBA::Utility.
# The function calls the osql.exe command line
# utilty with the backtick operator.

use strict;
use SQLDBA::Utility qw( dbaRunOsql );  # import the function

# Construct the SQL script
my $sql =<<__SQL__;
  use pubs
  go
  set nocount on
  set rowcount 2
  go
  if object_id('test') is not NULL
      drop table test
  go
  print 'Creating table test ...'
  create table test(id int, zip char(5))
  go
  print 'Inserting into table test ...'
  insert test values(1, '07410')
  insert test values(2, '07302')
  insert test values(3, '10024')
  go
  select * from test
__SQL__

# Prepare the osql command line options
my $optRef = {
      '-E' => undef,
      '-n' => undef,
      '-w' => '1024',
      '-d' => 'pubs',
      '-l' => '5'
   };

# Execute the SQL script on the APOLLO named instance on the local server
my $result = dbaRunOsql('.\APOLLO', $sql, $optRef);
if (!defined $result) {
   die "***Err: failed to run osql.exe.";
}
else {
   print $result;  # Print the results
}
