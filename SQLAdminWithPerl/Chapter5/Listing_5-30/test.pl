# This little script tests the function dbaGetTableConstraints() imported
# from the module SQLDBA:SQLDMO. It assumes that there is a SQL Server
# on the local server, and the named instance is APOLLO.

use strict;
use Data::Dumper;
use SQLDBA::SQLDMO qw( dbaGetTableConstraints );

my $tRef1 = {
   srvName => '.\APOLLO',
   dbName  => 'pubs',
   tbName  =>  'titleauthor'
};

my $ref = dbaGetTableConstraints($tRef1);
print Dumper($ref);

