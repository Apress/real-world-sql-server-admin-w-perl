# This script shows how to convert an arbitrary T-SQL
# script into a 'noramlized' version. A normalized T-SQL 
# script is a script where (1) a comment is replaced with
# a single alphanumeric, (2) a quoted string is replaced with 
# an alphanumeric string, and (3) an extended identifier is 
# replaced with a single alphanumeric.

use strict;
use SQLDBA::ParseSQL qw( dbaNormalizeSQL dbaRestoreSQL ); # import the two functions
use Data::Dumper;

# Get the file name from the command line
my $file = shift or die "***Err: $0 expects a file name.";

# Read the T-SQL script into a single variable $sql
my $sql;
open(SQL, "$file") or die "***Err: couldn't open $file for read.";
read(SQL, $sql, -s SQL);   # -s gets the total number of characters.
close(SQL);

# Normalize the SQL scripts
my $sqlRef = dbaNormalizeSQL($sql, 1);
print Dumper($sqlRef);

# Replace the token strings with their respective originals
$sqlRef= dbaRestoreSQL($sqlRef);
print $sqlRef->{code};