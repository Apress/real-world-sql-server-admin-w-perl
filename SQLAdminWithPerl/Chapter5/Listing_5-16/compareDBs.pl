# See the embedded POD or the HTML documentation

use strict;
use Getopt::Std;
use Data::Dumper;
use SQLDBA::SQLDMO qw( dbaGetTableColumns  dbaGetTableIndexes 
                       dbaGetTableConstraints  dbaScriptSP );
use SQLDBA::Utility qw( dbaSetDiff  dbaSetCommon  dbaRunQueryADO 
                        dbaStringDiff );
use SQLDBA::ParseSQL qw( dbaNormalizeSQL  dbaRestoreSQL );

my %opts;
getopts('ciS:D:s:d:', \%opts);  # c -- case sensitive, i -- ignore whitespace
Main: {
   my $optRef = {
               1 => { srvName => $opts{S},   # server name
                      dbName  => $opts{D}},  # database name
               2 => { srvName => $opts{s},   # server name
                      dbName  => $opts{d} }  # database name
      };
   
   my $objListRef = { 1 => getObjList($optRef->{1}),  # list of tables and SPs
                      2 => getObjList($optRef->{2})   # list of tables and SPs
      };
   compareTables($optRef, $objListRef);
   compareSPs($optRef, $objListRef, $opts{i}, $opts{c});
} # Main

####################
sub getObjList {
   my $optRef = shift or die "***Err: getObjList() expects a reference.";
   
   my $sql =<<END_SQL;
      use $optRef->{dbName}
      select 'name' = quotename(user_name(uid)) + '.' + quotename(name), 
             'type' = rtrim(type)
        from sysobjects
       where type in ('U', 'P')
         and objectproperty(id, 'IsMSShipped') = 0
END_SQL

   my $result = dbaRunQueryADO($optRef->{srvName}, $sql, 3);
   my $objListRef;
   foreach my $tn (@{shift @$result}) {
      push @{$objListRef->{$tn->{type}}}, $tn->{name};
   }
   return $objListRef;   
} # getObjList

####################
sub compareTables {
   my ($optRef, $objListRef) = @_;
   
   my $listRef1 = $objListRef->{1}->{U};
   my $listRef2 = $objListRef->{2}->{U};
   
   print "\nComparing tables (1) on $optRef->{1}->{srvName}";
   print " and (2) on $optRef->{2}->{srvName}:\n";
   if (my @diff = dbaSetDiff($listRef1, $listRef2)) {
      print "  Tables in (1), not in (2):\n";
      print "\t", join (",\n\t", @diff);
   }
   if (my @diff = dbaSetDiff($listRef2, $listRef1)) {
      print "\n\n  Tables not in (1), but in (2):\n";
      print "\t", join (",\n\t", @diff);
   }
   
   print "\n\nComparing common tables on both (1) and (2):\n";
   foreach my $tb (dbaSetCommon($listRef1, $listRef2)) {
      my $tRef1 = { srvName => $optRef->{1}->{srvName},
                    dbName  => $optRef->{1}->{dbName},
                    tbName  => $tb };
      my $tRef2 = { srvName => $optRef->{2}->{srvName},
                    dbName  => $optRef->{2}->{dbName},
                    tbName  => $tb };

      # Comparing columns
      my $ref1 = dbaGetTableColumns($tRef1);
      my $ref2 = dbaGetTableColumns($tRef2);
      compareCol($tRef1, $ref1, $tRef2, $ref2);

      # Comparing indexes      
      $ref1 = dbaGetTableIndexes($tRef1);
      $ref2 = dbaGetTableIndexes($tRef2);
      compareIdx($tRef1, $ref1, $tRef2, $ref2);
      
      # Comparing constraints
      $ref1 = dbaGetTableConstraints($tRef1);
      $ref2 = dbaGetTableConstraints($tRef2);
      compareConstraints($tRef1, $ref1, $tRef2, $ref2);
   }
} # compareTables

###################
sub compareSPs {
   my ($optRef, $objListRef, $ignoreWhitespace, $case) = @_;

   my $listRef1 = $objListRef->{1}->{P};
   my $listRef2 = $objListRef->{2}->{P};
   
   print "\n\nComparing stored procedures (1) on $optRef->{1}->{srvName}";
   print " and (2) on $optRef->{2}->{srvName}:\n";
   if (my @diff = dbaSetDiff($listRef1, $listRef2)) {
      print "  Stored procedures in (1), not in (2):\n";
      print "\t", join (",\n\t", @diff);
   }
   if (my @diff = dbaSetDiff($listRef2, $listRef1)) {
      print "\n  Stored procedures not in (1), but in (2):\n";
      print "\t", join (",\n\t", @diff);
   }
   
   print "\n\nComparing common stored procedures on both (1) and (2):\n";
   foreach my $sp (dbaSetCommon($listRef1, $listRef2)) {
      my $sRef1 = {srvName => $optRef->{1}->{srvName}, 
                   dbName  => $optRef->{1}->{dbName}, 
                   spName  => $sp };

      my $sRef2 = {srvName => $optRef->{2}->{srvName}, 
                   dbName  => $optRef->{2}->{dbName}, 
                   spName  => $sp };

      # get the scripts for the SPs
      my $ref1 = dbaScriptSP($sRef1);
      my $ref2 = dbaScriptSP($sRef2);

      # collapse the whitespaces, if specified
      if ($ignoreWhitespace) {   
         foreach my $ref ($ref1, $ref2) {
            my $sqlRef = dbaNormalizeSQL($ref->{Script}, 1);
            $sqlRef->{code} =~ s/\s+/ /g;    # whitespace -> single space
            $sqlRef = dbaRestoreSQL($sqlRef);
            $ref->{Script} = $sqlRef->{code};
         }      
      }     
      # now compare the SPs
      compareSP($sRef1, $ref1, $sRef2, $ref2, $ignoreWhitespace, $case);
   }
} # compareSPs

##################
sub compareCol {
   my ($tRef1, $ref1, $tRef2, $ref2) = @_;
   
   print "\nComparing (1) $tRef1->{tbName} on $tRef1->{srvName}.$tRef1->{dbName}";
   print " and (2) $tRef2->{tbName} on $tRef2->{srvName}.$tRef2->{dbName}:\n";
   print "   Checking column diff ...\n";
   if (my @diff = dbaSetDiff([keys %$ref1], [keys %$ref2])) {
      print "\tColumns in (1) $tRef1->{tbName}, not in (2) $tRef2->{tbName}:\n";
      print "\t", join (', ', @diff), "\n";
   }
   if (my @diff = dbaSetDiff([keys %$ref2], [keys %$ref1])) {
      print "\tColumns not in (1) $tRef1->{tbName}, but in (2) $tRef2->{tbName}:\n";
      print "\t", join (', ', @diff), "\n";
   }

   print "\n   Checking column property diff ...\n";
   foreach my $col (dbaSetCommon([keys %$ref1], [keys %$ref2])) {
      foreach my $prop (sort keys %{$ref1->{$col}}) {
         my $value1 = $ref1->{$col}->{$prop};
         my $value2 = $ref2->{$col}->{$prop};
         if ($value1 ne $value2) {
            print "\t$col, $prop: (1)=$value1, (2)=$value2\n";
         }
      }
   }
} # compareCol

##################
sub compareIdx {
   my ($tRef1, $ref1, $tRef2, $ref2) = @_;
   my ($tbName1, $tbName2) = ($tRef1->{tbName}, $tRef2->{tbName});
  
   print "\nComparing (1) $tbName1 on $tRef1->{srvName}.$tRef1->{dbName}";
   print " and (2) $tbName2 on $tRef2->{srvName}.$tRef2->{dbName}:\n";
   print "   Checking index diff ...\n";
   if (my @diff = dbaSetDiff([keys %$ref1], [keys %$ref2])) {
      print "\tIndexes in (1) $tbName1, not in (2) $tbName2:\n";
      print "\t", join (', ', @diff), "\n";
   }
   if (my @diff = dbaSetDiff([keys %$ref2], [keys %$ref1])) {
      print "\tIndexes not in (1) $tbName1, but in (2) $tbName2:\n";
      print "\t", join (', ', @diff), "\n";
   }

   print "\n   Checking index property diff ...\n";
   foreach my $idx (dbaSetCommon([keys %$ref1], [keys %$ref2])) {
      foreach my $prop (sort keys %{$ref1->{$idx}}) {
         my $value1 = $ref1->{$idx}->{$prop};
         my $value2 = $ref2->{$idx}->{$prop};
         if ($value1 ne $value2) {
            print "\t$idx, $prop: (1)=$value1, (2)=$value2\n";
         }
      }
   }
} # compareIdx

###########################
sub compareConstraints {
   my ($tRef1, $ref1, $tRef2, $ref2) = @_;
   my $tbName1 = "$tRef1->{srvName}.$tRef1->{dbName}.$tRef1->{tbName}";
   my $tbName2 = "$tRef2->{srvName}.$tRef2->{dbName}.$tRef2->{tbName}";
  
   foreach my $type ('Checks', 'Defaults', 'Keys') {
      print "\n   Checking $type diff ...\n";
      if (my @diff = dbaSetDiff([keys %{$ref1->{$type}}], 
                                [keys %{$ref2->{$type}}])) {
         print "\t$type in (1) $tbName1, not in (2) $tbName2:\n";
         print "\t", join (",\n\t", @diff), "\n";
      }
      if (my @diff = dbaSetDiff([keys %{$ref2->{$type}}], 
                                [keys %{$ref1->{$type}}])) {
         print "\t$type not in (1) $tbName1, but in (2) $tbName2:\n";
         print "\t", join (",\n", @diff), "\n";
      }

      print "\n   Checking $type property diff ...\n";
      foreach my $ck (dbaSetCommon([keys %{$ref1->{$type}}], 
                                   [keys %{$ref2->{$type}}])) {
         foreach my $prop (keys %{$ref1->{$type}->{$ck}}) { 
            my $value1 = $ref1->{$type}->{$ck}->{$prop};
            my $value2 = $ref2->{$type}->{$ck}->{$prop};
            if ($value1 ne $value2) {
               print "\t$ck: (1)=$value1, (2)=$value2\n";
            }
         }
      }
   }      
} # compareConstraints

##################
sub compareSP {
   my ($sRef1, $ref1, $sRef2, $ref2, $ignoreWhitespace, $case) = @_;
   my ($spName1, $spName2) = ($sRef1->{spName}, $sRef2->{spName});
  
   print "\nComparing (1) $sRef1->{srvName}.$sRef1->{dbName}.$sRef1->{spName}",
         " (2) $sRef2->{srvName}.$sRef2->{dbName}.$sRef2->{spName}";
   print "\n   Checking SP property diff ...\n";
   foreach my $prop (sort keys %$ref1) {
      next if $prop eq 'Script';
      my ($value1, $value2) = ($ref1->{$prop}, $ref2->{$prop});
      if ($value1 ne $value2) {
         print "\t$prop: (1)=$value1, (2)=$value2\n";
      }
   }
   print "\n   Comparing SP code diff ...\n";
   my $ref = dbaStringDiff($ref1->{Script}, $ref2->{Script}, 20, $case);
   if ($ref) {
      if ($ignoreWhitespace) {
         print "\tDiffering position: $ref->{pos}\n";
         print "\t        difference: $ref->{diff}\n";
      }
      else {
         print "\tDiffering position: $ref->{pos}\n";
         print "\t          line num: $ref->{line}\n";
         print "\t        difference: $ref->{diff}\n";
      }
   }
} # compareSP


__END__

=head1 NAME

compareDBs - Compare two databases for any schema difference

=head1 SYNOPSIS

 cmd>perl compareDBs.pl -S<Server name> -D<Database name>
                        -s<Server name> -d<Database name>
                        -c 
                        -i

   -S specifies the name of the first SQL Server.
   -D specifies the name of a database on the first server.
   -s specifies the name of the second SQL Server.
   -d specifies the name of database on the second server.
   -i instructs the comparison to ignore any whitespace. 
   -c makes the comparison case insensitive. 

=head1 DESCRIPTION

This script I<compareDBs.pl> compares two databases to report any schema difference that may exist between
them. This script basically the previous scripts in this chapter together. These previously discussed 
scripts compare individual aspects of databases, and they are:

=over

=item compareColumns.pl

=item compareIndexes.pl

=item compareConstraints.pl

=item compareSPs.pl

=back

The script I<compareDBs.pl> loops through all the tables, indexes, constraints, and SPs in 
the two databases, and compare them in turn. Comparing table columns, indexes, and constraints
are performed with the functions I<compareCol()>, I<compareIdx()>, and I<compareConstraints()>, 
respectively. These three functions mirror the scripts discussed in Listing 5-1, Listing 5-4, 
and Listing 5-11, respectively. They make up the function I<compareTables()> to perform the 
table comparison between the two databases.

The comparison of the stored procedures is performed by the function I<compareSPs()>, which 
follows the script I<compareSPs.pl> discussed in Listing 5-13.


=head1 USAGE EXAMPLE

The following is an example of running the script to compare the database pubs on the server
SQL01 and the database pubs on the server SQL02. Whitespaces are significant and the comparison is case
sensitive.

 cmd>perl compareDBs.pl -SSQL01 -Dpubs -sSQL02 -dpubs 

=head1 SAMPLE OUTPUT

The following is a sample output of running the script I<compareDBs.pl> as above:

   Comparing tables (1) on SQL01 and (2) on SQL02:
     Tables in (1), not in (2):
      [dbo].[test],
      [dbo].[writers],
      [dbo].[authors1],
      [dbo].[junk_1],
      [dbo].[au_ref],
      [dbo].[junk],

     Tables not in (1), but in (2):
      [dbo].[trash],
      [dbo].[snaptest],
      [dbo].[tbSysperf],
      [dbo].[repl_test],
      [dbo].[pub_info2]

   Comparing common tables on both (1) and (2):

   Comparing (1) [dbo].[stores] on SQL01.pubs and (2) [dbo].[stores] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[stores] on SQL01.pubs and (2) [dbo].[stores] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...

      Checking Keys property diff ...

   Comparing (1) [dbo].[employee] on SQL01.pubs and (2) [dbo].[employee] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[employee] on SQL01.pubs and (2) [dbo].[employee] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...
      Keys in (1) SQL01.pubs.[dbo].[employee], not in (2) SQL02.pubs.[dbo].[employee]:
      job_id:[dbo].[jobs]:job_id:yes

      Checking Keys property diff ...

   Comparing (1) [dbo].[pub_info] on SQL01.pubs and (2) [dbo].[pub_info] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[pub_info] on SQL01.pubs and (2) [dbo].[pub_info] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...

      Checking Keys property diff ...

   Comparing (1) [dbo].[jobs] on SQL01.pubs and (2) [dbo].[jobs] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[jobs] on SQL01.pubs and (2) [dbo].[jobs] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...

      Checking Keys property diff ...

   Comparing (1) [dbo].[titleauthor] on SQL01.pubs and (2) [dbo].[titleauthor] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[titleauthor] on SQL01.pubs and (2) [dbo].[titleauthor] on SQL02.pubs:
      Checking index diff ...
      Indexes in (1) [dbo].[titleauthor], not in (2) [dbo].[titleauthor]:
      UQ__titleauthor__75A278F5, UPKCL_taind, ix_ta, un_test, un_test2
      Indexes not in (1) [dbo].[titleauthor], but in (2) [dbo].[titleauthor]:
      PK__titleauthor__04AFB25B

      Checking index property diff ...

      Checking Checks diff ...
      Checks in (1) SQL01.pubs.[dbo].[titleauthor], not in (2) SQL02.pubs.[dbo].[titleauthor]:
      ([au_id] like '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]')

      Checking Checks property diff ...

      Checking Defaults diff ...
      Defaults in (1) SQL01.pubs.[dbo].[titleauthor], not in (2) SQL02.pubs.[dbo].[titleauthor]:
      royaltyper

      Checking Defaults property diff ...

      Checking Keys diff ...
      Keys in (1) SQL01.pubs.[dbo].[titleauthor], not in (2) SQL02.pubs.[dbo].[titleauthor]:
      title_id:[dbo].[titles]:title_id:yes,
      au_id,title_id:::yes,
      au_id:[dbo].[authors]:au_id:yes

      Checking Keys property diff ...
      au_id,title_id:::no: (1)=UPKCL_taind, (2)=PK__titleauthor__04AFB25B

   Comparing (1) [dbo].[titles] on SQL01.pubs and (2) [dbo].[titles] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[titles] on SQL01.pubs and (2) [dbo].[titles] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...

      Checking Keys property diff ...

   Comparing (1) [dbo].[authors] on SQL01.pubs and (2) [dbo].[authors] on SQL02.pubs:
      Checking column diff ...
      Columns in (1) [dbo].[authors], not in (2) [dbo].[authors]:
      contract

      Checking column property diff ...
      city, Length: (1)=22, (2)=20
      zip, AllowNulls: (1)=0, (2)=1
      zip, Length: (1)=9, (2)=5

   Comparing (1) [dbo].[authors] on SQL01.pubs and (2) [dbo].[authors] on SQL02.pubs:
      Checking index diff ...
      Indexes not in (1) [dbo].[authors], but in (2) [dbo].[authors]:
      ix_address

      Checking index property diff ...
      ix_idphone, FillFactor: (1)=0, (2)=10
      ix_idphone, PadIndex: (1)=no, (2)=yes
      ix_idphone, Unique: (1)=yes, (2)=no

      Checking Checks diff ...
      Checks in (1) SQL01.pubs.[dbo].[authors], not in (2) SQL02.pubs.[dbo].[authors]:
      ([state] like '[a-zA-Z][a-zA-Z]')

      Checking Checks property diff ...

      Checking Defaults diff ...
      Defaults in (1) SQL01.pubs.[dbo].[authors], not in (2) SQL02.pubs.[dbo].[authors]:
      state

      Checking Defaults property diff ...
      phone: (1)=('UNKNOWN'), (2)=('N/A')

      Checking Keys diff ...

      Checking Keys property diff ...

   Comparing (1) [dbo].[discounts] on SQL01.pubs and (2) [dbo].[discounts] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[discounts] on SQL01.pubs and (2) [dbo].[discounts] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...

      Checking Keys property diff ...

   Comparing (1) [dbo].[publishers] on SQL01.pubs and (2) [dbo].[publishers] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[publishers] on SQL01.pubs and (2) [dbo].[publishers] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...

      Checking Keys property diff ...

   Comparing (1) [dbo].[sales] on SQL01.pubs and (2) [dbo].[sales] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[sales] on SQL01.pubs and (2) [dbo].[sales] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...
      Keys in (1) SQL01.pubs.[dbo].[sales], not in (2) SQL02.pubs.[dbo].[sales]:
      title_id:[dbo].[titles]:title_id:yes

      Checking Keys property diff ...

   Comparing (1) [dbo].[roysched] on SQL01.pubs and (2) [dbo].[roysched] on SQL02.pubs:
      Checking column diff ...

      Checking column property diff ...

   Comparing (1) [dbo].[roysched] on SQL01.pubs and (2) [dbo].[roysched] on SQL02.pubs:
      Checking index diff ...

      Checking index property diff ...

      Checking Checks diff ...

      Checking Checks property diff ...

      Checking Defaults diff ...

      Checking Defaults property diff ...

      Checking Keys diff ...
      Keys in (1) SQL01.pubs.[dbo].[roysched], not in (2) SQL02.pubs.[dbo].[roysched]:
      title_id:[dbo].[titles]:title_id:yes

      Checking Keys property diff ...


   Comparing stored procedures (1) on SQL01 and (2) on SQL02:
     Stored procedures in (1), not in (2):
      [dbo].[spJunk],
      [dbo].[sp Call5],
      [dbo].[spCall2],
      [dbo].[spCall3],
      [dbo].[testSP],
      [dbo].[spCall],
      [dbo].[pr_authors]
     Stored procedures not in (1), but in (2):
      [dbo].[getAuid],
      [dbo].[usp_test],
      [dbo].[up_abc]

   Comparing common stored procedures on both (1) and (2):

   Comparing (1) SQL01.pubs.[dbo].[reptq1] (2) SQL02.pubs.[dbo].[reptq1]
      Checking SP property diff ...

      Comparing SP code diff ...
      Differing position: 178
                line num: 10
              difference: 

   GO

    <> GO



   Comparing (1) SQL01.pubs.[dbo].[reptq2] (2) SQL02.pubs.[dbo].[reptq2]
      Checking SP property diff ...
      AnsiNullsStatus: (1)=0, (2)=1
      QuotedIdentifierStatus: (1)=1, (2)=0

      Comparing SP code diff ...
      Differing position: 108
                line num: 3
              difference:  16), ytd_sales

   from <> 15), ytd_sales

   from 

   Comparing (1) SQL01.pubs.[dbo].[reptq3] (2) SQL02.pubs.[dbo].[reptq3]
      Checking SP property diff ...
      QuotedIdentifierStatus: (1)=1, (2)=0

      Comparing SP code diff ...

   Comparing (1) SQL01.pubs.[dbo].[byroyalty] (2) SQL02.pubs.[dbo].[byroyalty]
      Checking SP property diff ...
      AnsiNullsStatus: (1)=0, (2)=1

      Comparing SP code diff ...
      Differing position: 48
                line num: 3
              difference: /* Here are some /* k <> select au_id from tit


=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
