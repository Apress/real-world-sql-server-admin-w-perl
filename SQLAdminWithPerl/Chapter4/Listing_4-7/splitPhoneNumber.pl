# This script shows the power of Perl in identifying the patterns in text
# and reformatting the text.
# The script relies on the Text::CSV_XS to parse the CSV text and to 
# construct CSV text from arrays.

use strict;
use Text::CSV_XS;    # You can get this module from CPAN

my $csv = Text::CSV_XS->new({
     'quote_char'  => '"',
     'escape_char' => '"',
     'sep_char'    => ',',
     'binary'      => 0,
     'always_quote' => 1
   });

my @columns = ();
my @splitNumbers = ();
my $string;

while (<>) {
   if ($csv->parse($_)) {
      @columns = $csv->fields();  
      @splitNumbers =  splitPhoneNumber($columns[1]);  # split the area code and the phone number
      splice @columns, 1, 1, @splitNumbers;
   }
   if ($csv->combine(@columns)) {
      $string = $csv->string;
      print "$string\n";
   }
}

###########################
sub splitPhoneNumber {
    my ($phone) = shift;
    my ($areaCode, $local);
    
    $phone =~ /^(?: \s*(?:\d\s*[\-\.,\s]?)?  # in case of a prefix like 1-
                    \s* ( \(\s*\d\d\d\s*\) | \d\d\d )  # area code
                    \s* [\-\.,\s]? \s* )?    # some optional separator
                (\d\d\d) \s* [\-\.,\s]? \s* (\d\d\d\d)\s*$/x; # local number
    ($areaCode, $local) = ($1, "$2\-$3");
     $areaCode =~ s/^\s*\(\s*//;
     $areaCode =~ s/\s*\)\s*$//;
    return ($areaCode, $local);
}


__END__

=head1 NAME

splitPhoneNumber - Split free-form phone numbers into the area code and the local number

=head1 SYNOPSIS

 cmd>perl splitPhoneNumber.pl <CSV file>

=head1 DESCRIPTION

This script was written to demonstrate the power of Perl in handling this type of text
manipulation problems. It accepts a text file in the CSV format. The text file is assumed to
include multiple columns, the second of which contains phone numbers in the free text format.
The output of the script is also in the CSV format, but its second and third column now have 
the area codes and the local numbers, respectively, extracted from the original second column.

=head2 Phone Numbers in Free Text

The following is an example of the CSV files the script is expected to process:

 "1","212-647-5154","Wilson","Tom"
 "2","567-3214","North","Peter"
 "3","(201) 234-9865","West","Huge"
 "4","732.332-2346","Hill","John"
 "5","604 335-4525","Bush","Jean"
 "6","2087896537","Palmer","Ben"
 "7","(704) 5527212","Rogers","Ed"
 "8"," (734) 935  0978","Foster","Matt"
 "9","201.556.3245","Newman","Mark"
 "10","732,336-4245","Jones","Ted"
 "11","1-204-475-3045","Newfield","Brent"

=head2 Expacted Formats

The second column of the CSV file contains phone numbers that may be in any of the following 
formats:

=over

=item 1.

The phone number may start with a country code such as 1 for the US, and optionally 
followed with a separator, which may be a hyphen, a period, or a space.

=item 2. 

The phone number may or may not contain an area code, which may or may not be enclosed in
a pair of paentheses, followed by an optional separator such as a hyphen, a comma, a period, 
or a space.

=item 3.

The local number may or may include a separator.

=item 4.

In each of the above case, there may be arbitrary whitespaces around any element.

=back

=head2 Key Regular Expression

These expected formats are parsed with the following regular expression.

 $phone =~ /^(?: \s*(?:\d\s*[\-\.,\s]?)?                   # in case of a prefix like 1-
                 \s* ( \(\s*\d\d\d\s*\) | \d\d\d )         # area code
                 \s* [\-\.,\s]? \s* )?                     # some optional separator
             (\d\d\d) \s* [\-\.,\s]? \s* (\d\d\d\d)\s*$/x; # local number

If you find a format in your data that is not covered by this regular expression, just modify
the regular expression to include its pattern.

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.23

=cut
