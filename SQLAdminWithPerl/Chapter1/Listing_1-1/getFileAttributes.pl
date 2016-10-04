# Listing 1-1

use strict;

my $fileName = shift;
my ($size, $mdate) = (stat($fileName))[7,  9];

my $timeStr = localtime($mdate);

print "Size = $size, ModifyDate = $timeStr\n";
