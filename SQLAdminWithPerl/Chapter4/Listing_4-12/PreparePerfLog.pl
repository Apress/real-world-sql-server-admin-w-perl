# See the embedded POD or the HTML documentation for detail.

use strict;

my $log = shift or 
    die "***Err: Expects a performance counter log in the CSV format.\n";

# first get the columns on the first row. 
# the columns except the first one are the performance counter paths
open(LOG, "$log") or die "***Err: Could not open performance counter log $log.";
my $header = <LOG>;
my @counterPaths = getCounterPath($header);

# Now move on to process the rest of the rows
my $columnCount = scalar @counterPaths;
my $logRowCount = 0;
my $counterCount = 0;

while (<LOG>) {
   my @columns = map {/"(.+)"/; $1;} split (/,/, $_);
   my $row = undef;

   for (my $i = 0; $i < $columnCount; $i++) {
      print $columns[0] . "\t" 
                        . $counterPaths[$i]->[0] . "\t" 
                        . $counterPaths[$i]->[1] . "\t"
                        . $counterPaths[$i]->[2] . "\t"
                        . $counterPaths[$i]->[3] . "\t"                              
                        . $columns[$i+1] . "\n";
      ++$counterCount;
   }
   ++$logRowCount;
}
close(LOG);
print STDERR "$logRowCount log rows processed in total.\n";
print STDERR "$counterCount counter values processed in total.\n";

#########################
sub getCounterPath {
   my $header = shift;
   my @counterPaths;
   my @headings = map {/"(.+)"/; $1;} split (/,/, $header);

   shift @headings;   # discard the first column of the header
   foreach my $h (@headings) {
      my ($server, $object, $instance, $counter, $rest);

      if ($h =~ /^\\\\([^\\]+)\\(.+)$/) {   # match for the server name
         $server = $1; 
         $rest = $2;
         if ($rest =~ /^(.+)\\([^\\]+)$/) {  # match for counter name
            $object = $1;
            $counter = $2;
            if ($object =~ /^(.+)\((.+)\)$/) { # object followed by instance
                $object = $1;
                $instance = $2;         # object not followed by instance
            }
            else { $instance = ''; }
         }
         else {
            # shouldn't be here
            print STDERR "***Err: counter name format not expected for $h.\n";
         }
      }
      else {
         # shouldn't be here
         print STDERR "***Err: computer name format not expected for $h.\n";
      }
      # record the parsed counter paths for all the columns in an array
      push @counterPaths, [$server, $object, $instance, $counter];
   }
   return @counterPaths;
} # getCounterPath


__END__

=head1 NAME

preparePerfLog - convert the Perfmon log data to a format ready for bulk copy

=head1 SYNOPSIS

 cmd>perl preparePerfLog.pl <Perfmon Log CSV file> > <Fixed Column Data file>

=head1 DESCRIPTION

This script takes a Perfmon log file in the CSV format, and converts it to a 
tab-separated file with the fixed number of columns. The fixed-column data
file is ready to be bulk copied into a SQL Server table.

Note that the Perfmon log file in the CSV format is not suitable for bulk copy 
because (1) its columns vary when the Perfmon counters are added and dropped, and (2)
they are usually very wide.

=head1 STRUCTURE OF PERFMON LOGS

We are talking about the structure of the Windows performance counter log as created by the Performance Logs 
and Alerts tool. To keep the discussion brief, assume that you’ll log two counters on the server SQL01: 

 Memory\Pages/sec 
 PhysicalDisk(0 D:)\% Disk Time
 
In the counter log, each counter is identified by what is known as the counter path, which is a 
combination of computer name, performance object, performance instance, instance index, and 
performance counter. A counter path typically follows this format:

 \\Computer_name\Object_name(Instance_name#Index_Number)\Counter_name
 
Using this notation of the counter path, your two performance counters are identified as 
follows in the counter log:

 \\SQL01\Memory\Pages/sec
 \\SQL01\PhysicalDisk(0 D:)\% Disk Time

The entries of the counter log in the CSV file format should look like the following: 

 "(PDH-CSV 4.0) (Eastern Daylight Time)(240)","\\SQL01\Memory\Pages/sec","\\SQL01\PhysicalDisk(0 D:)\% Disk Time"
 "09/08/2002 12:35:45.166","11.296813511113458","7.0625001143654654e"
 "09/08/2002 12:36:00.167","0.26679653905997197","2.8829087316668804"
 "09/08/2002 12:36:15.169","0.13331924737007395","2.0239260004978679"

As the new counters are added, they’re added as comma-separated new columns. 
Note that adding or dropping a counter results in the log data written to a new 
log file. For a given log file, the number of columns is fixed and doesn’t change. 
Every time the counter values are recorded in the log, a new line containing all t
he counter values is appended to the log with the first column providing the time stamp.

=head1 TABLE STRUCTURE

Several alternative table schemas can adequately handle the performance counter data. 
The following is a straightforward table structure, although it may not be most 
optimal spacewise.

CREATE TABLE tbSysperf (
       LogTime       datetime        NOT NULL ,
       Server        varchar (128)   NOT NULL ,
       Object        varchar (128)   NOT NULL ,
       Instance      varchar (128)   NULL ,
       Counter       varchar (128)   NOT NULL ,
       Value         float           NULL
)

=head1 PREPARED DATA FORMAT

Using the example Perfmon CSV file and the above table tbSysperf, the script preparePerfLog.pl
produces the following:

 09/08/2002 12:35:45.166 SQL01   Memory      Pages/sec   11.296813511113458
 09/08/2002 12:35:45.166 SQL01   PhysicalDisk   0 D:  % Disk Time 7.0625001143654654e
 09/08/2002 12:36:00.167 SQL01   Memory      Pages/sec   0.26679653905997197
 09/08/2002 12:36:00.167 SQL01   PhysicalDisk   0 D:  % Disk Time 2.8829087316668804
 09/08/2002 12:36:15.169 SQL01   Memory      Pages/sec   0.13331924737007395
 09/08/2002 12:36:15.169 SQL01   PhysicalDisk   0 D:  % Disk Time 2.0239260004978679

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2002.12.30

=cut
