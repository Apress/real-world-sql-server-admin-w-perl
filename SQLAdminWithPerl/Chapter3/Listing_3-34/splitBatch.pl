# This script shows how to split a T-SQL scrcipt into
# individual batches. The batch terminator is GO. 
# The function dbaSplitBatch() is defined in this 
# script. You can also import the a more robust version of 
# this function from the module SQLDBA::ParseSQL.

use strict;
use Data::Dumper;

# Construct the sample T-SQL script
my $sql =<<END_SQL;
use pubs
go    
sp_help
go   
sp_helpdb
go 

END_SQL

# Split the T-SQL script into batches and print the data structure that
# stores the batches.
print Dumper(dbaSplitBatch($sql));


#####################
sub dbaSplitBatch {
  my ($sql) = shift or die"***Err: dbaSplitBatch() expects a string.\n";
  
  $sql =~ s/^\s*\n//;
  my @batches = split(/\ngo\s*\n/i, $sql);

  \@batches;  
} # dbaSplitBatch
