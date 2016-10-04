# Listing 1-5

use strict;

my $db = 'master';
my $sql = <<END_SQL;   # Note there is no space between << and END_SQL
USE $db
GO
SELECT * FROM sysobjects
GO
END_SQL

print $sql;
