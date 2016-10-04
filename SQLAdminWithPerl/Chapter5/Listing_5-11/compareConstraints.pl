use strict;
use Data::Dumper;
use SQLDBA::SQLDMO qw( dbaGetTableConstraints );
use SQLDBA::Utility qw( dbaSetDiff dbaSetCommon );

Main: {
   my $tRef1 = { srvName => '.\apollo',
                 dbName  => 'pubs',
                 tbName  => 'titleauthor'};
   my $tRef2 = { srvName => '.\pantheon',
                 dbName  => 'pubs',
                 tbName  => 'titleauthor'};

   # get table constraints
   my $ref1 = dbaGetTableConstraints($tRef1);
   my $ref2 = dbaGetTableConstraints($tRef2);
   # compare table constraints
   compareConstraints($tRef1, $ref1, $tRef2, $ref2);
} # Main

###########################
sub compareConstraints {
   my ($tRef1, $ref1, $tRef2, $ref2) = @_;
   my $tbName1 = "$tRef1->{srvName}.$tRef1->{dbName}.$tRef1->{tbName}";
   my $tbName2 = "$tRef2->{srvName}.$tRef2->{dbName}.$tRef2->{tbName}";
  
   foreach my $type ('Checks', 'Defaults', 'Keys') {
      print "\n   Checking $type diff ...\n";
      if (my @diff = dbaSetDiff([keys %{$ref1->{$type}}], 
                                [keys %{$ref2->{$type}}])) {
         print "\t$type in (1) $tbName1, not in (2) $tbName2:\n";
         print "\t", join (",\n\t", @diff), "\n";
      }
      if (my @diff = dbaSetDiff([keys %{$ref2->{$type}}], 
                                [keys %{$ref1->{$type}}])) {
         print "\t$type not in (1) $tbName1, but in (2) $tbName2:\n";
         print "\t", join (",\n", @diff), "\n";
      }

      print "\n   Checking $type property diff ...\n";
      foreach my $ck (dbaSetCommon([keys %{$ref1->{$type}}], 
                                   [keys %{$ref2->{$type}}])) {
         foreach my $prop (keys %{$ref1->{$type}->{$ck}}) { 
            my $value1 = $ref1->{$type}->{$ck}->{$prop};
            my $value2 = $ref2->{$type}->{$ck}->{$prop};
            if ($value1 ne $value2) {
               print "\t$ck: (1) = $value1, (2) = $value2\n";
            }
         }
      }
   }      
} # compareConstraints


__END__

=head1 NAME

compareConstraints - Compare two tables for any difference in their constraints

=head1 SYNOPSIS

 cmd>perl compareConstraints.pl

For illustration purposes, the server instances, the databases, and the tables are all 
hard coded in the script. You can esily modify the script to accept a config file or 
retrieve the server info from the command line.

=head1 DESCRIPTION

This script shows how to compare two tables for any difference in their constraints. The types of 
constraints include:

=over

=item * Primary Keys

=item * Unique Keys

=item * Foreign Keys

=item * Check Constraints

=item * Default Constraints

=back

The approach is to (1) retrieve the information about the constraints of each table using SQL-DMO, (2)
store the information in a Perl data structure, and (3) compare the two data structures.

The script relies on the I<dbaGetTableConstraints()> function imported from the module SQLDBA::SQLDMO
to obtain the information on the table constraints. The script also imports two utility 
functions, I<dbaSetDiff()> and I<dbaSetCommon()>, to help with comparing the data structures. 
These two functions are imported from the module SQLDBA::Utility.

To see the behavior of this script, you can systematically alter the properties of these constraints 
and run the script after each change.


The structure of this script is similr to that of the script I<compareColumns.pl> in Listing 5-1 
or that of the script I<compareIndexes.pl> in Listing 5-4.

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
