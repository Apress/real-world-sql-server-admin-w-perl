/* This script is to compare two specific indexes */

use strict;
use warnings;
use Data::Dumper;
use SQLDBA::SQLDMO qw( dbaGetIndexInfo );
use SQLDBA::Utility qw( dbaSetDiff dbaSetCommon );

Main: {
   my $iRef1 = { srvName => '.\apollo',
                 dbName  => 'pubs',
                 tbName  => 'dbo.authors',
                 idxName => 'ix_idphone'};
   my $iRef2 = { srvName => '.\pantheon',
                 dbName  => 'pubs',
                 tbName  => 'dbo.authors',
                 idxName => 'ix_idphone'};

   my $ref1 = dbaGetIndexInfo($iRef1);
   my $ref2 = dbaGetIndexInfo($iRef2);
   compareIdx($iRef1, $ref1, $iRef2, $ref2);
} # Main

##################
sub compareIdx {
   my ($iRef1, $ref1, $iRef2, $ref2) = @_;
   my ($idxName1, $idxName2) = ($iRef1->{idxName}, $iRef2->{idxName});
  
   print "Comparing (1) $idxName1 on $iRef1->{srvName}.$iRef1->{dbName}.$iRef1->{tbName}";
   print " and (2) $idxName2 on $iRef2->{srvName}.$iRef2->{dbName}.$iRef2->{tbName}:\n";

   if (!$ref1) {
      print "\n   Failed to find any info on $idxName1.\n";
   }
   if (!$ref2) {
      print "\n   Failed to find any info on $idxName2.\n";
   }
   
   if ($ref1 && $ref2) {
      print "\n   Checking index property diff ...\n";
      foreach my $prop (sort keys %$ref1) {
         my $value1 = $ref1->{$prop};
         my $value2 = $ref2->{$prop};
         if ($value1 ne $value2) {
            print "\t$prop: (1) = $value1, (2) = $value2\n";
         }
      }
   }
} # compareIdx
