use strict;
use Data::Dumper;
use SQLDBA::SQLDMO qw( dbaGetTableIndexes );
use SQLDBA::Utility qw( dbaSetDiff dbaSetCommon );

Main: {
   my $tRef1 = { srvName => '.\apollo',
                 dbName => 'pubs',
                 tbName => 'dbo.authors'};
   my $tRef2 = { srvName => '.\pantheon',
                 dbName => 'pubs',
                 tbName => 'authors'};

   my $ref1 = dbaGetTableIndexes($tRef1);
   my $ref2 = dbaGetTableIndexes($tRef2);
   compareIdx($tRef1, $ref1, $tRef2, $ref2);
} # Main

##################
sub compareIdx {
   my ($tRef1, $ref1, $tRef2, $ref2) = @_;
   my ($tbName1, $tbName2) = ($tRef1->{tbName}, $tRef2->{tbName});
  
   print "Comparing (1) $tbName1 on $tRef1->{srvName}.$tRef1->{dbName}";
   print " and (2) $tbName2 on $tRef2->{srvName}.$tRef2->{dbName}:\n";
   print "   Checking index diff ...\n";
   if (my @diff = dbaSetDiff([keys %$ref1], [keys %$ref2])) {
      print "\tIndexes in (1) $tbName1, not in (2) $tbName2:\n";
      print "\t", join (', ', @diff), "\n";
   }
   if (my @diff = dbaSetDiff([keys %$ref2], [keys %$ref1])) {
      print "\tIndexes not in (1) $tbName1, but in (2) $tbName2:\n";
      print "\t", join (', ', @diff), "\n";
   }

   print "\n   Checking index property diff ...\n";
   foreach my $idx (dbaSetCommon([keys %$ref1], [keys %$ref2])) {
      foreach my $prop (sort keys %{$ref1->{$idx}}) {
         my $value1 = $ref1->{$idx}->{$prop};
         my $value2 = $ref2->{$idx}->{$prop};
         if ($value1 ne $value2) {
            print "\t$idx, $prop: (1) = $value1, (2) = $value2\n";
         }
      }
   }
} # compareIdx


__END__

=head1 NAME

compareIndexes - Compare two tables for any index difference

=head1 SYNOPSIS

 cmd>perl compareIndexes.pl

For illustration purposes, the server instances, the databases, and the tables are all 
hard coded in the script. You can esily modify the script to accept a config file or 
retrieve the server info from the command line.

=head1 DESCRIPTION

This script shows how to compare two tables for any difference in their indexes.

The approach is to (1) retrieve the information about the indexes of each table using SQL-DMO, (2)
store the information in a Perl data structure, and (3) compare the two data structures.

The script relies on the I<dbaGetTableIndexes()> function imported from the module SQLDBA::SQLDMO
to obtain the information on the table indexes. The script also imports two utility 
functions, I<dbaSetDiff()> and I<dbaSetCommon()>, to help with comparing the data structures. 
These two functions are imported from the module SQLDBA::Utility.

To see the behavior of the script, you can make the following modifictions to one of the table, and
run the script after each change:

=over

=item * Add a new index to one table

=item * Change the index keys of a common index on one table

=item * Change the clustered index on one table to non-clustered

=item * Change the fillfactor of an index on one table

=back

The structure of this script is similr to that of the script compareColumns.pl in Listing 5-1.

=head1 COMPARE INDEXES

The script I<compareIndexes.pl> compares two tables for ny difference in their indexes. If you want to
compare two indexes for any difference, take a look at the script I<compareIndexInfo.pl>, which allows 
you to specify the index names in addition to the server names, database names, and the tble names.

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
