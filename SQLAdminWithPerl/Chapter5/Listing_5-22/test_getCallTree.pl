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

my $callTree = getCallTree($srvRef);
$srvObj->Close();
print Dumper($callTree);

####################
sub findSPCalls {
   my $script = shift or die "***Err: findSPCalls() expects a string.";
   
   my $spRef = dbaNormalizeSQL($script, 0);
   
   my @calledSPs;
   while ($spRef->{code} =~
                        /(?<![\w\@\#\$])  # negative lookbehind
                          EXEC(UTE)?      # keywords EXECUTE or EXEC
                          \s+(\@.+?=\s*)? # return variable and whitespaces
                          ([^(\s]+)       # proc name
                        /igx) {           # case insensitive and match all
         my $sp = $3;
         # replace tokens with their originals (bracket_id's)
         foreach my $token (keys %{$spRef->{bracket_ids}}) {
            $sp =~ s/$token/$spRef->{bracket_ids}->{$token}/e;
         }
         # replace tokens with their originals (double_id's)
         foreach my $token (keys %{$spRef->{double_ids}}) {
            $sp =~ s/$token/$spRef->{double_ids}->{$token}/e;
         }
         push @calledSPs, $sp;
   }
   return @calledSPs;
} # findSPCalls

####################
sub getCallTree {
   my $ref = shift or die "***Err: getCallTree() expects a reference.";
#print "DB: $ref->{dbName}, SP: $ref->{spName}\n";

   my $owner = 'dbo.'; # default to dbo
   my %callTree;
   my $spRef = dbaScriptSP2($ref) or return \%callTree;
   my @SPs = findSPCalls($spRef->{Script});
   foreach my $sp (@SPs) {
      if ($sp =~ /^\s*([^\s]+)\.([^\s]*\.[^\s]+)/) {
         ($ref->{dbName}, $sp) = ($1, $2);
         $sp =~ s/^\s*\./$owner/e;
      }
      next if $sp =~ /^($ref->{spName}|$owner\.$ref->{spName})/;
      my $subTree = getCallTree( { srvObj => $ref->{srvObj},
                                   dbName => $ref->{dbName},
                                   spName => $sp } );
      $callTree{$ref->{dbName}. '.' . $sp} = $subTree;  # add to the tree
   }
   return \%callTree;
} # getCallTree
