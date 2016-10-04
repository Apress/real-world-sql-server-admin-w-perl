use strict;
use SQLDBA::SQLDMO qw( dbaScriptSP2 );
use SQLDBA::ParseSQL qw( dbaNormalizeSQL );
use Win32::OLE;
use Data::Dumper;

my $ref = { srvName => '.\apollo',
            dbName  => 'pubs',
            spName  => 'spCall' };
       
my $srvObj = Win32::OLE->new('SQLDMO.SQLServer')
      or die "***Err: Could not create SQLDMO object.";
$srvObj->{LoginSecure} = 1;
$srvObj->connect($ref->{srvName}, '', '');
! Win32::OLE->LastError() or
      die "***Err: Could not connect to $ref->{srvName}.";
   
my $srvRef = { srvObj => $srvObj,
               dbName => $ref->{dbName},
               spName => $ref->{spName} };

my $spRef = dbaScriptSP2($srvRef);
my @SPs = findSPCalls($spRef->{Script});

$srvObj->Close();

print Dumper(\@SPs);

sub findSPCalls {
   my $script = shift or die "***Err: findSPCalls() expects a string.";
   
   my $spRef = dbaNormalizeSQL($script, 0);
print Dumper($spRef);
   
   my @calledSPs;
   while ($spRef->{code} =~ /(?<![\w\@\#\$])
                              EXEC(UTE)?
                              \s+(\@.+?=\s*)?
                              ([^(\s]+)
                            /igx) {
         my $sp = $3;
         foreach my $token (keys %{$spRef->{bracket_ids}}) {
            $sp =~ s/$token/$spRef->{bracket_ids}->{$token}/e;
         }
         foreach my $token (keys %{$spRef->{double_ids}}) {
            $sp =~ s/$token/$spRef->{double_ids}->{$token}/e;
         }
         push @calledSPs, $sp;
   }
   return @calledSPs;
} # findSPCalls