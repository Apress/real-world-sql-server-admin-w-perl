# This script checks a data file for comformance to the expected format.
# See the embedded POD or the HTML documentation for detail.

use strict;

# These variables define the expected format
# Begin config options
   my $fieldTerminator = '\|';               # the fields are separated with the pipe symbol
   my $rowTerminator = "\n";                 # the row is terminated with a newline
   my $columnCount = 9;                      # 9 fields are expected in each row
   my %columnPatterns = (
            0 => qr/^\d{3}\-\d{2}\-\d{4}$/,  # the pattern for the first column
            7 => qr/^\d{5}$/                 # the pattern for the 8th column
      );
# End config options

Main: {
   $/ = $rowTerminator;                # set the Perl row terminator

   my ($total, $errCount) = (0, 0);
   while(<>) {
      s/$rowTerminator$//;
      ++$total;
      my @columns = split /$fieldTerminator/;
      my $OK = 1;
      
      # Check column count
      unless ($columnCount == scalar @columns) {
         $OK = 0;
         print "***Err: the number of columns is not $columnCount";
         print "        for row $_\n";
         next;
      }
      # Check column patterns
      foreach my $col (sort keys %columnPatterns) {
         unless ($columns[$col] =~ /$columnPatterns{$col}/) {
            $OK = 0;
            print "***Err: column $columns[$col] failed to match pattern";
            print " $columnPatterns{$col}\n";
            print "        for row $_\n";
         }
      }
      ++$errCount unless $OK;
   }
   print "\n$total rows checked in total.\n";
   print "$errCount rows mismatched.\n";
}


__END__

=head1 NAME

validateImport - validate data in a file for conformance to the expected format

=head1 SYNOPSIS

 cmd>perl validateImport.pl Data_File

=head1 DESCRIPTION

This script checks whether the rows in a data file conform to the expect format. The format
is defined with the following parameters

 Field terminator  -- the character(s) that separates two consecutive fields in a row
 Row termintor -- the character(s) that marks the end of a row
 The number of fields in a row
 The pattern of a field

The script reads from the data file, one row at a time. It then splits the row by the field
separator into an array of field values. For each field, the script checks whether it
comply with the expected format.

Such a script is useful when you bulk copy data into a SQL Server table, and want to find 
the bad rows before performing the bulk copy. The script is also useful if you need to 
troubleshoot bulk copy failure caused by data format problems.

=head1 FORMAT VARIABLES

The following four variables in the script help define the expected format:

=over

=item $fieldTerminator

This variable specifies the character(s) that separates two neighboring fields

=item $rowTemintor

This variable specifies the character(s) that ends each row.

=item $columnCount

This variable specifies the number of fields (i.e. columns) each row is expected to have.

=item %columnPattern

The keys of this hash are the column indexes, which are zero based. The corresponding
value is a regular expression defining the expected pattern that the field must comply
with.

=back 

=head1 TESTS

Two sample data files are included in the same folder where you find this script. One of 
the files contains bad data, i.e. data that doesn't comform to the expected pattern, and
this file is named authors_bad.txt. The other file contains perfectly formatted data, and 
is named authors_good.txt. 

To test the script, run it on the command line from the current folder with one of these 
data files.

=over

=item Bad Data

 cmd>perl validateImport.pl authors_bad.txt
 
The expected output is as follows

 ***Err: column 1722-32-1176 failed to match pattern (?-xism:^\d{3}\-\d{2}\-\d{4}$)
         for row 1722-32-1176|Linchi|Victor|408 496-7223|10932 Bigge Rd.|Menlo Park|CA|94025|1

 23 rows checked in total.
 1 rows mismatched.

=item Good Data 
 
  cmd>perl validateImport.pl authors_good.txt
 
The expected output is as follows:

 23 rows checked in total.
 0 rows mismatched.

=back

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2002.12.30

=cut
