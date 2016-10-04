# See the embedded POD or the HTML documentation for detail

use strict;
use Getopt::Std;
use SQLDBA::SQLDMO qw( dbaScriptSP );
use SQLDBA::ParseSQL qw( dbaNormalizeSQL dbaRestoreSQL );
use SQLDBA::Utility qw( dbaStringDiff );

my %opts;
getopts('ciS:D:P:s:d:p:', \%opts);  # get the command line arguments
my ($case, $ignoreWhitespace) = ($opts{c}, $opts{i});

# Place the command line arguments into two hashes
my $sRef1 = {srvName => $opts{S}, 
             dbName  => $opts{D}, 
             spName  => $opts{P}};

my $sRef2 = {srvName => $opts{s}, 
             dbName  => $opts{d}, 
             spName  => $opts{p}};

Main: {
   # get the scripts for the SPs
   my $ref1 = dbaScriptSP($sRef1);
   my $ref2 = dbaScriptSP($sRef2);

   # collapse the whitespaces, if specified
   if ($ignoreWhitespace) {   
      foreach my $ref ($ref1, $ref2) {
         my $sqlRef = dbaNormalizeSQL($ref->{Script}, 1);
         $sqlRef->{code} =~ s/\s+/ /g;    # whitespace -> single space
         $sqlRef = dbaRestoreSQL($sqlRef);
         $ref->{Script} = $sqlRef->{code};
      }      
   }     
   # now compare the SPs
   compareSP($sRef1, $ref1, $sRef2, $ref2, $ignoreWhitespace);
} # Main


##################
sub compareSP {
   my ($sRef1, $ref1, $sRef2, $ref2, $ignoreWhitespace, $case) = @_;
   my ($spName1, $spName2) = ($sRef1->{spName}, $sRef2->{spName});
  
   print "Comparing (1) $sRef1->{srvName}.$sRef1->{dbName}.$sRef1->{spName}" .
         " (2) $sRef2->{srvName}.$sRef2->{dbName}.$sRef2->{spName}";
   print "\n   Checking SP property diff ...\n";
   foreach my $prop (sort keys %$ref1) {
      next if $prop eq 'Script';
      my ($value1, $value2) = ($ref1->{$prop}, $ref2->{$prop});
      if ($value1 ne $value2) {
         print "\t$prop: (1)=$value1, (2)=$value2\n";
      }
   }
   print "\n   Comparing SP code diff ...\n";
   my $ref = dbaStringDiff($ref1->{Script}, $ref2->{Script}, 20, $case);
   if ($ref) {
      if ($ignoreWhitespace) {
         print "\tDiffering position: $ref->{pos}\n";
         print "\t        difference: $ref->{diff}\n";
      }
      else {
         print "\tDiffering position: $ref->{pos}\n";
         print "\t          line num: $ref->{line}\n";
         print "\t        difference: $ref->{diff}\n";
      }
   }
} # compareSP


__END__

=head1 NAME

compareSPs - Compare two stored procedures for difference

=head1 SYNOPSIS

 cmd>perl compareSPs.pl -S<Server name> -D<Database name> -P<SP Name>
                        -s<Server name> -d<Database name> -p<SP Name>
                        -c 
                        -i

The upper case arguments introduce one stored procedure, and the lower case arguments introduce
another.

The -c argument makes the string comparison case insensitive, and the -i argument instructs the script
to ignore any difference in whitespaces.

=head1 DESCRIPTION

This script compares two stored procedures to see whether they are the same. If they are different, 
it prints the first 22 characters of each SP from where the two start to differ.

The approach is to (1) retrieve the information about the stored procedures from online SQL Server
instances and script them
using SQL-DMO, (2) store the information in a Perl data structure, and (3) compare 
the two data structures. 

For the T-SQL code, the script calls the function I<dbaScriptSP()> to generate the T-SQL scripts for the two
stored procedures. 
The I<dbScriptSP()> is exported from the module SQLDBA::SQLDMO. The script then calls the function
I<dbaStringDiff()> imported from the module SQLDBA::Utility to compare the two SPs as two strings.

Note that, in addition to comparing the text of the T-SQL code, you also need to compare the
properties of the two stored procedures. The script compares two stored procedures with respect 
to the following four properties:

=over

=item * its ANSI Null status

=item * its owner

=item * its Quoted Identifier status

=item * is it marked for startup?

=back

=head1 DATA STRUCTURE

The script stores the information about a stored procedure in a hash with its values corresponding to 
the above four properties. In additon, the T-SQL code of the stored procedure is also stored as
a hash value.

The following is an example of the data structure that stores the information about a stored
procedure:

 $spRef = {
           'Script' => 'CREATE PROC testSP
                        AS
                        -- a very simple test SP
                          SELECT @@version
                        GO',
           'QuotedIdentifierStatus' => 1,
           'Owner' => 'dbo',
           'AnsiNullsStatus' => 1,
           'Startup' => 0
         };


When you have retrieved the information about the two stored procedures and stored the information 
in two hashes similar to the
one shown above, comparing the two hashes is all you need to do in order to find whether the two 
stored procedures are different and exactly what are the differences. The function
I<compareSP()> defined in the script performs the hash comparison.

=head1 NORMALIZING T-SQL CODE

The script accepts a -i command line switch, which instructs the script to ignore any whitespace 
difference. It turns out to be non-trivial to identify the real whitespaces. Once they 
are identified, to ignore them in the comparison is to first collapse multiple consecutive whitespaces
into a single whitespace before the comparison.

The typical whitespace character include: a space, a tab, and a newline

The following may look like whitespace, but are in fact significant:

=over

=item * Anything inside a quoted string

=item * Anything inside a double quoted identifier

=item * Anything inside a square brcket quoted identifier

=item * Anything inside a comment

=back

The function I<dbaNormlizeSQL()> is called to replace a quoted string, a delimited identifier, 
or a comment with a unique alphanumeric string. You can then search the I<normalized> T-SQL code
for any pattern you may care to search without tripping over any significant tabs, spaces, and delimited
identifiers, and comments. In this script, the normalized T-SQL script allows us to collapse whitespaces
without changing any significant tabs, spaces, identifiers, or comments.

After the script finishes collapsing the whitespaces, it replaces the unique strings introduced by the
function I<dbaNormalizeSQL()> with their corresponding originals, and restores the T-SQL code
to its original minus the collapsed whitespaces.
The function for accomplishing this is I<dbaRestoreSQL()>.

The function I<dbaNormalizeSQL()> is generally useful when dealing with T-SQL scripts,
and you'll see it used in many scripts in this book.

=head1 EXAMPLE

The following is an example of running the script to compare two stored procedures in two pubs databases 
on two named instances on the local server.
The best way to see how the script behaves is to modify one of stored procedures, and then run the script
to see how it reports the difference.


 cmd>perl compareSPs.pl -S.\apollo -Dpubs -Pdbo.byroyalty -s.\pantheon -d pubs -p dbo.byroyalty
 Comparing (1) .\apollo.pubs.dbo.byroyalty (2) .\pantheon.pubs.dbo.byroyalty
   Checking SP property diff ...
   AnsiNullsStatus: (1)=0, (2)=1

   Comparing SP code diff ...
   Differing position: 48
             line num: 3
           difference: (1) /* Here are some /* k <> (2) select au_id from title

This example shows that the ANSI Nulls setting for the two stored procedures are different. The
two stored procedures also start to become different t charcter position 48 on line 3. From position 
48 onward, the stored procedure I<byroyalty> on the instance .\apollo includes the following string: 

 /* Here are some /* k <>
 
And the stored procedure I<byroylty> on the instance .\pntheon includes the following string:

 select au_id from title
 

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
