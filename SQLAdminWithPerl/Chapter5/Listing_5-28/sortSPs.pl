# See the embedded POD or the HTML documentation

use strict;
use Getopt::Std;
use SQLDBA::ParseSQL qw( dbaNormalizeSQL dbaSplitBatch );

# get command line arguments
my $optRef = getCommandLineOpt();

Main: {
   # read the script into $sql
   my $sql;
   open(SQL, "$optRef->{f}") or 
      die "***Err: could not open $optRef->{f} for read.";
   read(SQL, $sql, -s SQL);     # read (-s SQL) number of bytes from file handle SQL and assign it to $sql
   close(SQL);

   # get SPs immediately called
   my ($spCallRef, $sqlRef) = getSPCall($sql, $optRef->{d});

   # normalize IDs
   $spCallRef = normalizeID($spCallRef, $sqlRef, $optRef);

   # fill in the default
   $spCallRef = fillInSP($spCallRef);

   # Sort the procedures by dependency
   my $sortedSPRef = sortObjs($spCallRef);

   print "Stored procedures in dependency order:\n";
   foreach (@$sortedSPRef) { print "\t$_\n"; }
} # Main

###################
sub printUsage {
    print <<__USAGE__;
Usage:    
  cmd>perl sortSPs.pl [-c ] [-o <owner>] -d <db> -f <T-SQL file>
    
  Options:
     -d    set the default database name
     -o    set the default object owner name
     -c    1 = case sensitive, 0 = case insensitive
     -f    name of the T-SQL script file that includes all the SPs
__USAGE__
    exit;
}  # printUsage

############################
sub getCommandLineOpt {
   my %opts;

   getopts('d:o:cf:', \%opts);
   $opts{f} or printUsage();

   # set default to case insensitive
   $opts{c} = 0 unless defined $opts{c};
   return \%opts;
}  # getCommandLineOpt

##############################
sub getSPCall {
   my ($sql, $db) = @_;
   my $spCallRef;

   my $sqlRef = dbaNormalizeSQL($sql, 0);
 
   foreach my $batch (@{ dbaSplitBatch($sqlRef->{code}) }) {
      if ($batch =~ /^\s*use\s+(\w+)/i) {
         $db = $1;
      }
      my ($proc, $dependRef) = findSPExec($batch);
      next unless $proc;   # skip if CREATE PROC(EDURE) not in the batch

      $spCallRef->{$proc} = {
            depends => $dependRef,
            db      => $db
         };
   }
   return ($spCallRef, $sqlRef);
}  # getSPCall

#######################
sub findSPExec {
   my $batch = shift;
   my $proc;
   my @depends;

   if ($batch =~ /\bCREATE\s+(?:PROC|PROCEDURE)\s+(\w+\.\w+|\w+)/i) {
      $proc = $1;
      while ($batch =~ /\b(?:EXEC|EXECUTE)\s+
                          (?:\@\w+\s*=\s*)?
                          (\w+\.\w*\.\w+|\w+\.\w+|\w+)
                       /igx) {
         push @depends, $1 
      }                        
   }
   ($proc, [@depends]);
} # findSPExec

#######################
sub normalizeID {
   #   1. change all double-quoted id's to bracket-quoted id's
   #   2. change all IDs to lower case, if case insensitive
   #   3. change all proc name in $spCallRef to the standard three-part
   #   4. restore the original names

   my ($spCallRef, $sqlRef, $optRef) = @_;

   # change double-quoted ids to square-bracket-quoted
   foreach (keys %{$sqlRef->{double_ids}}) {
      $sqlRef->{double_ids}->{$_} =~ s/\"\"/\"/g;  # un-escapte "
      $sqlRef->{double_ids}->{$_} =~ s/\]/\]\]/g;  # escape [
      $sqlRef->{bracket_ids}->{$_} = $sqlRef->{double_ids}->{$_};
   }
   $sqlRef->{double_ids} = [];  # set double-delimited id list to empty

   my $spCallNormalRef;
   my $c = $optRef->{c};
   foreach my $sp (keys %$spCallRef) {
      # work on the key
      my $db = $c ? $spCallRef->{$sp}->{db} : lc($spCallRef->{$sp}->{db});
      my $normalSP;
      if ($sp =~ /\w+\.\w+/) {
         $normalSP = "$db." . ($c ? $sp : lc($sp));
      }
      else {
         $normalSP = "$db.dbo." . ($c ? $sp : lc($sp));
      }

      # work on the array elements
      $spCallNormalRef->{$normalSP} = [];  # initialize to no dependency
      foreach my $depend (@{$spCallRef->{$sp}->{depends}}) {
         my $normalDepend;
         if ($depend =~ /^\w+\.\w+\.\w+$/) {
            $normalDepend = $c ? $depend : lc($depend);
         }
         elsif ($depend =~ /^(\w+)\.\.(\w+)$/) {
            $normalDepend = ($c ? $1 : lc($1)) . '.dbo.' . 
                            ($c ? $2 : lc($2));
         }
         elsif ($depend =~ /^(\w+)\.(\w+)$/) {
            $normalDepend = "$db." . ($c ? $depend : lc($depend));
         }
         else {
            $normalDepend = "$db.dbo." . ($c ? $depend : lc($depend));
         }
         push @{$spCallNormalRef->{$normalSP}}, $normalDepend;
      }
   }
   
   # restore the original names
   foreach my $sp (keys %$spCallNormalRef) {
      foreach my $dep (@{$spCallNormalRef->{$sp}}) {
         if ($dep =~ /(\w+)\.(\w+)\.(\w+)/) {
            my ($db, $owner, $obj) = ($1, $2, $3);
            $db    =~ s/\]/\]\]/g;
            $owner =~ s/\]/\]\]/g;
            $obj   =~ s/\]/\]\]/g;
            $dep = "[$db].[$owner].[$obj]";
         }
         foreach my $id (keys %{$sqlRef->{bracket_ids}}) {
            $dep =~ s/\b$id\b/$sqlRef->{bracket_ids}->{$id}/;
         }
      }
      my $tmp = $spCallNormalRef->{$sp};
      delete $spCallNormalRef->{$sp};
      
      if ($sp =~ /(\w+)\.(\w+)\.(\w+)/) {
         my ($db, $owner, $obj) = ($1, $2, $3);
         $db    =~ s/\]/\]\]/g;
         $owner =~ s/\]/\]\]/g;
         $obj   =~ s/\]/\]\]/g;
         $sp = "[$db].[$owner].[$obj]";
      }
      foreach my $id (keys %{$sqlRef->{bracket_ids}}) {
         $sp =~ s/\b$id\b/$sqlRef->{bracket_ids}->{$id}/;
      }
      $spCallNormalRef->{$sp} = $tmp;
   }
   return $spCallNormalRef;
} # normalizeID

#################
sub fillInSP {
   my $spCallRef = shift;
   
   # if a proc is called, but not defined in the script
   # set it to depend on nothing
   foreach my $sp (keys %$spCallRef) {
      foreach my $depend (@{$spCallRef->{$sp}}) {
         unless (exists $spCallRef->{$depend}) {
            $spCallRef->{$depend} = [];
         }
      }
   }
   return $spCallRef;
} # fillInSP

###################
sub sortObjs {
    my($dependRef) = shift or die "***Err: sortObjs() expects a reference.";
    my @sorted = ();
    return \@sorted unless keys %$dependRef > 0;

    # move all non-dependent SPs to @sorted
    foreach my $sp (keys %$dependRef) {

        # skip it if it depends on other SPs
        next if scalar @{$dependRef->{$sp}} > 0;
        
        # Now $sp is non-dependent, add it to @sorted
        push @sorted, $sp;

        # remove the non-dependent $sp
        foreach my $p (keys %{$dependRef}) {
            $dependRef->{$p} = [grep {$sp ne $_} @{$dependRef->{$p}}];
        }
        delete $dependRef->{$sp};
    }

    # if @sorted is empty at this point, there is circular dependency
    if (scalar @sorted == 0) {
        print "***Err: circular dependency!\n";
        print Dumper($dependRef);
        die;
    }

    # if the tree is not empty, recursively work on what's left
    push @sorted, @{ sortObjs($dependRef) } if keys %$dependRef > 0;

    return \@sorted;
}  # sortObjs


__END__

=head1 NAME

sortSPs - Sort the stored procedures defined in a T-SQL script by dependency

=head1 SYNOPSIS

  cmd>perl sortSPs.pl [-c ] [-o <owner>] -d <db> -f <T-SQL file>
    
  Options:
     -d    set the default database name
     -o    set the default object owner name
     -c    case sensitive, if specified
     -f    name of the T-SQL script file that includes all the SPs

=head1 SAMPLE USAGE

The following example shows the results of running the script I<sortSPs.pl> on the
T-SQL script file someSPs.sql, which includes the definitions of several stored
procedures. 


 cmd>perl sortSPs.pl -d pubs -f test.sql -c 
 Stored procedures in dependency order:
       '[pubs].[dbo].[myProc]',
       '[pubs].[dbo].[reptq2 - Exec]',
       '[pubs].[dbo].[orderSP]',
       '[pubs].[dbo].[reptq1]',
       '[pubs].[dbo].[checkSP]',
       '[pubs].[dbo].[cutSP]',
       '[pubs].[dbo].[loadSP]'


=head1 DESCRIPTION

The script I<sortSPs.pl> sorts the stored procedures defined in a T-SQL script file by dependency. 
This script first scans the T-SQL script file to identify the immediate dependencies of each SP. 
In other words, it first finds out the stored procedures directly called by every stored procedure.

The script then proceeds to normalize the identifiers used in the T-SQL. This ensures that the same object
is identified by the same normalized identifier. This is necessary because in T-SQL an object can be 
identified in different ways. All these different identifiers are about the same object and therefore 
should be replaced with a consistently named identifier during the sorting. 

This replacement of 
identifiers with a consistent anming convention also applies to any identifier that is not fully 
qualified. A default database name and a default owner are used to fully qualify such an identifier.

Now, the script is ready to do the real work of sorting SPs by dependency. This is the job of the 
function I<sortObjs()>.

=head1 IDENTIFYING IMMEDIATE DEPENDENCIES

The first step in the script I<sortSPs.pl> is to identify the immediate dependencies of the stored
procedures defined in the T-SQL script file. The immediate dependencies of a stored procedure are the 
stored procedures called directly in the T-SQL script with the EXECUTE statements. 

Before discussing how to identify the immeidate dependencies, let's look at the data structure that
represents the immediate dependencies.

=head2 Representing Immediate Dependencies

A hash of arrays is used to represent the immediate dependencies of the stored procedures defined
in the T-SQL script. For each stored procedure defined in the T-SQL script, its name is a key in this
hash, and the value of the hash is a reference to an array whose elements are the names of the 
stored procedures called in the CREATE PROCEDURE statement of this stored procedure.

The following is an example of the data structure:

 $ref = {
          '[pubs].[dbo].[spProc]' => [ ],
          '[pubs].[dbo].[reptq1]' => [
                                 '[pubs].[dbo].[reptq2 - Exec]'
                               ],
          '[pubs].[dbo].[reptq2 - Exec]' => [ ],
          '[pubs].[dbo].[spCheck]' => [
                                  '[pubs].[dbo].[reptq1]'
                                ],
          '[pubs].[dbo].[spCut]' => [
                                '[pubs].[dbo].[reptq1]',
                                '[pubs].[dbo].[spCheck]',
                                '[pubs].[dbo].[spProc]',
                                '[pubs].[dbo].[spOrder]'
                              ],
          '[pubs].[dbo].[spOrder]' => [ ],
          '[pubs].[dbo].[spLoad]' => [
                                 '[pubs].[dbo].[spCheck]',
                                 '[pubs].[dbo].[spCut]',
                                 '[pubs].[dbo].[spOrder]',
                                 '[pubs].[dbo].[reptq1]'
                               ]
        };


If an array is empty, it means that the corresponding stored procedure doesn't call any other stored
procedure.

=head2 Finding Immediate Dependencies

The key steps are similar to those used in the I<callTree.pl> script to construct the call 
tree for a stored procedure:

=over

=item 1

Normalize the script with the function I<dbaNormalizeSQL()> to remove the complications 
caused by T-SQL comments, quoted strings, and delimited identifiers.

=item 2

Split the script into batches by the batch terminator GO.

=item 3

For each batch, parse the script of each CREATE PROCEDURE to find the stored procedures 
called with the EXECUTE statement.
The functions I<getSPCall()> and I<findSPExec()> in Listing 5-26 implement these steps.

=back

=head1 SORTING STORED PROCEDURES

Having captured a hash of arrays shown previously, you can perform the following steps 
to populate an array with the stored procedures sorted by dependency. 
Assume that the hash of arrays is %depend, and the sorted stored 
procedures are in @sorted:

=over

=item 1

Initialize the array @sortedSP to empty.

=item 2

Push into @sorted those stored procedures of %depend that don’t have 
any dependencies. If you can’t find any stored procedure with no dependency 
and the hash %depend is not empty, there’s a circular dependency. That’s treated 
as a fatal error condition. 

=item 3

Delete the hash entries of those stored procedures that have been pushed into @sorted 
and remove the stored procedures from any array referenced in the hash.

=item 4

Repeat step 2 until the hash %depend is empty.

=back

These steps are recursive. Moreover, they’re not particular to sorting stored procedures 
but are generic. As long as the immediate dependencies are captured in a hash of arrays, 
irrespective of what each element may represent or the nature of the dependencies, 
the outlined steps will sort the elements by dependency.

The I<sortObjs()> function in the script implements these steps.

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
