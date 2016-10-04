# This script shows how to generate the T-SQL script for a given stored
# procedure, using the function dbaScriptSP() defined in the module
# SQLDBA::SQLDMO.

# Note that it may takes many seconds to load the module for the 
# first time because it takes time to load SQL-DMO.

use strict;
use SQLDBA::SQLDMO qw( dbaScriptSP );  # impoprt the function
use Data::Dumper;

# Specify the test server and stored procedure to be scripted
my $ref = {
     srvName => '.\apollo',
     dbName  => 'pubs',
     spName  => 'reptq1'
};

# Generate the T-SQL script
my $spRef = dbaScriptSP($ref);

# print the generated script
print Dumper($spRef);
