# This script shows how to run a SQL query or a batch of SQL query 
# using the function dbaRunQueryADO(). This function is imported
# from the module SQLDBA::Utility. The function uses the 
# Win32:OLE module to invoke the ADO COM Automation objects.

use strict;
use Data::Dumper;
use SQLDBA::Utility qw( dbaRunQueryADO );  # import the function

# Construct the SQL queries
my $sql = <<__SQL__;
   use pubs
   set nocount on
   set rowcount 3
   select * from pubs..titles
   select au_id, au_lname, au_fname, phone from authors
__SQL__

# Execute the queries on SQL instance apollo on the local
# machine. Set the connection timeout to 3 seconds. This
# returns the resultsets in an array of hashes, each array
# element representing a resultset and each hash representing
# a record.
my $ref = dbaRunQueryADO('.\apollo', $sql, 3);

# Print out the resultset
print Dumper($ref);
