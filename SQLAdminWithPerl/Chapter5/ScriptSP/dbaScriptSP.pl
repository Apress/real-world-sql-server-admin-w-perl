# for test only

use strict;
use Win32::OLE;
use Win32::OLE::Const 'Microsoft SQLDMO';


my $serverName = '.\apollo';
my $dbName = 'pubs';
my $spName = 'byroyalty';


my $sql = dbaScriptSP($serverName, $dbName, $spName);
print $sql;

sub dbaScriptSP {
   my ($serverName,$dbName, $spName) = @_;
   
   my $server = Win32::OLE->new('SQLDMO.SQLServer') or
        die "***Err: could not create SQLDMO object.\n";
   $server->{LoginSecure} = 1;

   $server->connect($serverName, '', '');
   ! Win32::OLE->LastError() or 
       die "***Err: SQLDMO could not connect to $serverName.\n";

   my $obj = $server->Databases($dbName)->StoredProcedures($spName);
   my $sql = $obj->Script(SQLDMOScript_Default);

   $server->disconnect();
   $server->DESTROY();
   return $sql;
}
