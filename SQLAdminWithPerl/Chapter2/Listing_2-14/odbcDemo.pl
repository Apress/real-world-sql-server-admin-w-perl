# This script demonstrates how to connect to a SQL Server instance 
# using the Win32::ODBC module.

use strict;
use Data::Dumper;
use Win32::ODBC;

# Get the SQL instance name from the command line
my $server = shift 
   or die "***Err: $0 expects a server name.";

# Construct the connect string for the ODBC driver
my $connStr = "Driver={SQL Server};Server=$server;Trusted_Connection=yes";

# Make the connection to the SQL instance
my $conn = Win32::ODBC->new($connStr) 
    or die "***Err: " . Win32::ODBC::Error();

# Prepare the SQL statement
my $sql = "select * from pubs..authors where phone like '408%'";

# Execute the SQL statement
if (! $conn->Sql($sql)) {
   while ($conn->FetchRow()) {       # get the next row in the resultset
      my %data = $conn->DataHash();  # get the column values into a hash
      print Dumper(\%data);          # display the hash
   }
}

# Close the connection
$conn->Close();
