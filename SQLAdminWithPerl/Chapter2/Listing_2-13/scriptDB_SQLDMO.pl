# This script illustrates the use of the SQLDMO Automation features
# from a Perl script. The interface is through the Win32::OLE module.
# he script generates a database creation T-SQL script.

use strict;
use Win32::OLE 'in';     # import the in method
use Win32::OLE::Const 'Microsoft SQLDMO';  # import all the constants

# Get the SQL instance name
my $serverName = shift 
    or die "***Err: $0 expects a SQL instance name.\n";

# Request to create a SQLDMO COM object
my $server = Win32::OLE->new('SQLDMO.SQLServer2')
     or die "**Err: could not create SQLDMO object.";

# Set the connection to use trusted SQL connection
$server->{LoginSecure} = 1;   

# Actually make the connection
$server->connect($serverName);
! Win32::OLE->LastError() or
    die "***Err: could not connect to $serverName.";

# For each database, script out its T-SQL script
foreach my $db (in($server->Databases())) {
   unless ($db->{Name} =~ /^(pubs|northwind|test)$/i) {
      print "-- Database: ", $db->{Name}, "\n";
      my $sql = $db->Script(SQLDMOScript_Default  | SQLDMOScript_Drops |
                            SQLDMOScript_IncludeHeaders );
      print "$sql\n";
   }
}
$server->DisConnect();
