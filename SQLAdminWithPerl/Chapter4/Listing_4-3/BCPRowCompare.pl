# This script scans the row numbers in two bcp log files, one for
# bulk copy out and the other for bulk copy in, and then compare
# the numbers for the same table to determine whether the number 
# of thw rows copied in is the same as the number of the rows
# copied out.

# See the BCPRowCompare.html or the embedded POD for more details.

use strict;
use Getopt::Std;
use Data::Dumper;

my $dbName  = q/(?:[\w@#]+ | \"(?:[^"]|\\\")+\")/;
my $objName = q/(?:[\w@#]+ | \"(?:[^"]|\\\")+\" | \[(?:[^]]|\]\])+\])/;

my %opts;
getopts('i:o:', \%opts);

(defined $opts{i} and defined $opts{o}) or printUsage();

my %inout = ( 'in' => $opts{i}, 'out' => $opts{o} );
my ($ref, $object);

foreach my $io (keys %inout) {
   open(LOG, $inout{$io}) or die "***Err: could not open $inout{$io}.";
   while (<LOG>) {
      if (/\>\s*bcp\s+(\"(?:[^"]|\\\"|\"\")+\")\s+$io/ix) {
         $object = $1;
         next;
      }
      if (/\>\s*bcp\s+$dbName\.($objName)?\.($objName)\s+$io/ix) {
         $object = $2;
         next;
      }
      if (/(\d+)\s+rows\s+copied/i) {
         if (defined $object) {
            $ref->{$object}->{$io . '_rowcount'}=$1;
         }
         else {
            print "***Err: The regular expressions parsing the bcp command\n";
            print "        line is inadequate. The script should not be here.\n"
         }
         undef $object;
      }
   }
   close(LOG);
}

my $ok = 1;
foreach my $obj (sort keys %$ref) {
    if ($ref->{$obj}->{in_rowcount} != $ref->{$obj}->{out_rowcount}) {
        print "***Msg for $obj: BCP out $ref->{$obj}->{out_rowcount} rows ";
        print "<> BCP in $ref->{$obj}->{in_rowcount} rows.\n";
        $ok = 0;
    }
}

print "\n*** All table rows match.\n\n" if $ok;
print Data::Dumper->Dump([$ref], ['RowCounts']);

############################
sub printUsage {
############################
    print << '--Usage--';
Usage:    
   cmd>perl BCPRowCompare.pl -i <bcp in log> -o <bcp out log>
--Usage--
exit;
} # printUsage


__END__

=head1 NAME

BCPRowCompare - Compare numbers of rows BCPed in and BCPed out 

=head1 SYNOPSIS

 cmd>perl BCPRowCompare.pl -i <BCP in log file> -o <BCP out log file>

=head1 DESCRIPTION

This script was written to (1) retrieve, from a BCP-in log file, the numbers of rows bulk copied 
out of SQL Server database tables, (2) retrieve, from a BCP-out log file, the numbers of rows bulk 
copied into SQL Server database 
tables, and (3) compare the number of rows BCPed in with the number of rows BCPed out for each
table. The script simplifies the validation process when a large number of tables has to be 
migrated using the SQL Server bulk copy utility.

The output of the bulk copying all the tables should be directed to the same log file introduced 
by -i option, while all the output of bulk copying out data from all the tables should be 
directed to a single log file as specified by -o option.

The comparison is conducted in two steps:

=over

=item Step 1

The script reads the BCP-in log file and records the number of rows BCPed for each table, and the 
script then reads the BCP-out
log file to record the number of rows BCPed out for each table.

=item Step 2

For each table, the script compares the recorded number of rows BCPed in with the number of rows BCPed out,
and reports the difference, if any.

=back 


=head1 AUTHOR

Linchi Shea

=head1 VERSION

2002.01.14

=cut
