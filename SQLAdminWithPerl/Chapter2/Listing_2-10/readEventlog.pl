# This script illustrates how to use the module Win32::Eventlog
# to read the NT eventlog entries on any server, local or remote

use strict;
use Win32::EventLog;

# Get the server name from the command line argument
my $server = shift or die "***Err: $0 expects a server name.";

# Initialize how many days to scan, going backward
my $cutoff_days = 2;

# Scan the system log only for illustration purposes
my $log = 'system';
$Win32::EventLog::GetMessageText = 1; # To generate the Message hash key

print "\nServer=$server\n";

my($logRef, $eventRef);

# $cutoff is the number of seconds since the cutoff day
my $cutoff = time() - $cutoff_days * 24 * 3600;

# Get the handle the system eventlog on the server
$logRef = Win32::EventLog->new($log, $server) 
         or die "***Err: could not open $log on $server.\n";

# Read the log records backward from the lastest until the cutoff
while ( $logRef->Read(EVENTLOG_BACKWARDS_READ | 
                      EVENTLOG_SEQUENTIAL_READ, 0, $eventRef) &&
      $cutoff < $eventRef->{TimeGenerated}) {

   # Print only the informational message
   if ( $eventRef->{EventType} == EVENTLOG_INFORMATION_TYPE ) {
      print scalar localtime($eventRef->{TimeGenerated}), ', ';
      print $eventRef->{Message}, "\n";
   }
} 
$logRef->Close();
