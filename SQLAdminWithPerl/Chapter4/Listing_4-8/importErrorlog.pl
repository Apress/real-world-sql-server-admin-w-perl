# This script parses the SQL Server errorlog entries. Each entry is 
# converted to a neatly formatted row with four fields, 
# separated with a pipe symbol, and the row is terminated with the 
# string @#$.

use strict;

my $entryCounter = 0;
my $entry = <>;
while(<>) {
   if (!/^\d\d(\d\d)?\-\d\d\-\d\d\s+\d\d\:\d\d\:\d\d\.\d\d
          \s+
          [^\s]+
          \s+
        /x) {
      $entry .= $_;
   }
   else {
      ++$entryCounter;
      if ($entry =~ /^(\d\d(?:\d\d)?\-\d\d\-\d\d\s+ # date
                      \d\d\:\d\d\:\d\d\.\d\d)\s+   # time
                     ([^\s]+)\s+                   # source
                     (.+)$                         # the rest
                   /xs) {
         my ($datetime, $source, $msg) = ($1, $2, $3);
         print "$entryCounter\|$datetime\|$source\|$msg\@\#\$";
      }
      else {
         print STDERR "***Assert Err: should not reach here.\n";
      }
      $entry = $_;
   }
}
++$entryCounter;
if ($entry =~ /^(\d\d(?:\d\d)?\-\d\d\-\d\d\s+ # date
                 \d\d\:\d\d\:\d\d\.\d\d)\s+   # time
                ([^\s]+)\s+                   # source
                (.+)$                         # the rest
             /xs) {
   my ($datetime, $source, $msg) = ($1, $2, $3);
   print "$entryCounter\|$datetime\|$source\|$msg\@\#\$";
}
else {
   print STDERR "***Assert Err: should not reach here.\n";
}
print STDERR "***$entryCounter entrys processed.\n";


__END__

=head1 NAME

importErrorlog - Reformat a SQL Server errorlog for bulk copy program

=head1 SYNOPSIS

 cmd>perl importErrorlog.pl Errorlog_File > Formatted_Errorlog_File

=head1 DESCRIPTION

This script converts a SQL Server errorlog into a consistent format ready for 
the bulk copy program. The new format uses the pipe symbol as the field terminator
and the string @#$ as the row terminator.

A SQL Server errorlog entry begins with a date/time string and finishes just before
the next date/time string. Note that a SQL Server errorlog entry cna span multiple 
lines. Also, note that even though a SQL Server errorlog entry is already divided into
several fields, separated by space. The bulk copy program can't rely on the spaces to 
determine where one field ends and the next begins. There are often too many embedded
spaces, which makes spaces unsuitable as the field termintor.

Despite that its name may suggests otherwise, importErrorlog.pl doesn't really import 
anything anywhere. It merely reformat a data file for bulk copy. Once the data is 
massaged into the expected format, performing bulk copy becomes easy.


=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
