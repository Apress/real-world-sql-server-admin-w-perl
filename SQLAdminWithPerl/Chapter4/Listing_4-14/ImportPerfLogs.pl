my $log = shift;

open(LOG, "$log") or die "***Error: Could not open perflog file $log.";
my @headings = map {/"(.+)"/; $1;} split (/,/, <LOG>);
foreach my $h (@headings) {
    my ($server, $object, $instance, $counter);
    my $rest;
    if ($h =~ /^\\\\([^\\]+)\\(.+)$/) { 
        $server = $1; 
        $rest = $2;
        if ($rest =~ /^([^\\]+)\\(.+)$/) {
            $object = $1;
            $counter = $2;
            if ($object =~ /^(.+)\((.+)\)$/) {
                $object = $1;
                $instance = $2;
            }
            else { $instance = ''; }
        }
    }
    @split_headings = (@split_headings, [$server, $object, $instance, $counter]);
}

use Win32::ODBC;

my $sqlServer = "LINCHI\\APOLLO";
my $db = new Win32::ODBC ("Driver={SQL Server};Server=$sqlServer;Trusted_Connection=Yes;Database=pubs") 
   or die 'Error: '. Win32::ODBC::Error();

my $j = scalar @headings;
my $sql;
while (<LOG>) {
     my @columns = map {/"(.+)"/; $1;} split (/,/, $_);
     my $i;
     $sql = undef;
     
     for ($i = 1; $i < $j; $i++) {
         $sql = "insert tb_" . $split_headings[$i]->[0] . "_sysperf ";
         $sql .= "(log_time, server, object, instance, counter, value) ";
         $sql .= "values('" . $columns[0] . "', '" . $split_headings[$i]->[0] . "', '";
         $sql .= $split_headings[$i]->[1] . "', ";
         if ($split_headings[$i]->[2]) {
               $sql .= "'" . $split_headings[$i]->[2] . "', ";
         }
         else {
               $sql .= "NULL, ";
         }
         $sql .= "'" . $split_headings[$i]->[3] . "', ";                                  

         if ($columns[$i] !~ /^[\.\d]+$/) { $columns[$i] = '0'; }
         $sql .= $columns[$i] . ")";

         if ($db->Sql( $sql )) {
            print "***Err: Failed to insert $columns[0] data." . Win32::ODBC::Error();
         }
     }
}

$db->Close();
