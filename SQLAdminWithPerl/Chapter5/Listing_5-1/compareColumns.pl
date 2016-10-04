# See the embedded POD or the HTML documentation for detail

use strict;
use warnings;
use SQLDBA::SQLDMO qw( dbaGetTableColumns );
use SQLDBA::Utility qw( dbaSetDiff dbaSetCommon );

Main: {
   # for illustration purposes, I've hard coded the table names
   # in the next two hashes
   my $tRef1 = { srvName => '.\apollo',
                 dbName => 'pubs',
                 tbName => 'dbo.authors'};
   my $tRef2 = { srvName => '.\pantheon',
                 dbName => 'pubs',
                 tbName => 'authors'};

   # get the column information for each table
   my $ref1 = dbaGetTableColumns($tRef1);
   my $ref2 = dbaGetTableColumns($tRef2);
   # compare the columns in $ref1 and $ref2
   compareCol($tRef1, $ref1, $tRef2, $ref2);
} # Main

##################
sub compareCol {
   my ($tRef1, $ref1, $tRef2, $ref2) = @_;
   
   print "Comparing (1) $tRef1->{tbName} on $tRef1->{srvName}.$tRef1->{dbName}";
   print " and (2) $tRef2->{tbName} on $tRef2->{srvName}.$tRef2->{dbName}:\n";
   print "   Checking column diff ...\n";
   # determine columns that are in table1 but not in table2
   if (my @diff = dbaSetDiff([keys %$ref1], [keys %$ref2])) {
      print "\tColumns in (1) $tRef1->{tbName}, not in (2) $tRef2->{tbName}:\n";
      print "\t", join (', ', @diff), "\n";
   }
   # determine columns that are in table2 but not in table1
   if (my @diff = dbaSetDiff([keys %$ref2], [keys %$ref1])) {
      print "\tColumns not in (1) $tRef1->{tbName}, but in (2) $tRef2->{tbName}:\n";
      print "\t", join (', ', @diff), "\n";
   }

   # for the common columns, determine whether any properties are different
   print "\n   Checking column property diff ...\n";
   foreach my $col (dbaSetCommon([keys %$ref1], [keys %$ref2])) {
      foreach my $prop (sort keys %{$ref1->{$col}}) {
         my $value1 = $ref1->{$col}->{$prop};
         my $value2 = $ref2->{$col}->{$prop};
         if ($value1 ne $value2) {
            print "\t$col, $prop: (1) = $value1, (2) = $value2\n";
         }
      }
   }
} # compareCol


__END__

=head1 NAME

compareColumns - Compare the columns of two tables for schema difference

=head1 SYNOPSIS

 cmd>perl compareColumns.pl

For illustration purposes, the server instances, the databases, and the tables are all 
hard coded in the script. You can esily modify the script to accept a config file or 
retrieve the server info from the command line.

=head1 DESCRIPTION

This script shows how to compare the columns of two tables for any difference in their schema.

The approach is to (1) retrieve the schema information about the columns of each table using SQL-DMO, (2)
store the schema information in a Perl data structure, and (3) compare the two data structures.

The script relies on the I<dbaGetTableColumns()> function imported from the module SQLDBA::SQLDMO
to obtain the schema information on the table columns. The script also imports two utility 
functions, I<dbaSetDiff()> and I<dbaSetCommon()>, to help with comparing the data structures. 
These two functions are imported from the module SQLDBA::Utility.

The hard coded tables are the pubs..authors tables in two different databases. To see how the 
script works, change the columns of one table and then run the script. For instance, you can add
a new column to one authors table, and run the script to see whether it reports the difference 
in terms of this new column and how it reports the difference.

=head1 LOADING SQL-DMO  

SQL-DMO is invoked through the module Win32::OLE, which is the gatewy to any OLE Automation from Perl. 
The rest is simply to sollow the hierarchy of a specific object model. The Win32::OLE module is not
directly used in this script. It's used in the imported function I<dbaGetTbleColumns()>.

Note that the first when this script tries to load SQL-DMO, it may take several seconds. Subsequent
runs of the script should be lot quicker.

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
