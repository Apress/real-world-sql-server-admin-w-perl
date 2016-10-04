# See the embedded POD or HTML documentation

use strict;
use Getopt::Std;
use SQLDBA::ParseSQL qw( dbaNormalizeSQL dbaSplitBatch );
use Data::Dumper;

# get command line arguments
my $optRef = getCommandLineOpt();

Main: {
   my $spCallRef;
   my $sp2FileRef;
   
   foreach my $file (glob($optRef->{f})) {
      # read the script into $sql
      my $sql;
      open(SQL, "$file") or 
         die "***Err: could not open $file for read.";
      read(SQL, $sql, -s SQL);
      close(SQL);

      # get SPs immediately called
      my ($spDependRef, $sqlRef) = getSPCall($sql, $optRef->{d});

      # normalize IDs
      $spDependRef = normalizeID($spDependRef, $sqlRef, $optRef);
      
      # capture SP-to-file mapping
      foreach my $proc (keys %$spDependRef) {
         $sp2FileRef->{$proc} = $file;
      }
      
      # Add the immediate dependencies from this T-SQL file to 
      # the overall immediate dependency data structure
      foreach my $proc (keys %$spDependRef) {
         push @{$spCallRef->{$proc}}, @{$spDependRef->{$proc}}
      }
   }

   # fill in the default
   $spCallRef = fillInSP($spCallRef);

   # Sort the procedures by dependency
   my $sortedSPRef = sortObjs($spCallRef);

   foreach my $proc (@$sortedSPRef) {
      print "\t$sp2FileRef->{$proc}\n" if $sp2FileRef->{$proc};
   }
} # Main

###################
sub printUsage {
    print <<__USAGE__;
Usage:    
  cmd>perl sortSPFiles.pl [-c ] [-o <owner>] -d <db> -f <T-SQL files>
    
  Options:
     -d    set the default database name
     -o    set the default object owner name
     -c    1 = case sensitive, 0 = case insensitive
     -f    names of the T-SQL script files, wildcards are OK
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

sortSPFiles - Sort stored procedure script files by dependency

=head1 SYNOPSIS

  cmd>perl sortSPFiles.pl [-c ] [-o <owner>] -d <db> -f <T-SQL files>
    
  Options:
     -d    set the default database name
     -o    set the default object owner name
     -c    1 = case sensitive, 0 = case insensitive
     -f    names of the T-SQL script files, wildcards are OK

=head1 SAMPLE OUTPUT

 cmd>perl sortSPFiles.pl -d pubs -f .\test\*.* 
    .\test\reptq2.PRC
    .\test\reptq1.PRC
    .\test\anotherSP.PRC
    .\test\anSP_0.PRC
    .\test\anSP.PRC
    .\test\poorly_NamedSP.PRC


=head1 DESCRIPTION

You can reduce this problem to the one solved with the script I<sortSPs.pl> in Listing 5-28.
The following are the steps to reuse the code in the script I<sortSPs.pl> from Listing 5-28:

=over

=item 1

Scan through all the T-SQL scripts to generate a mapping from each stored procedure name 
to the name of a file, where the stored procedure is defined.

=item 2

Concatenate all the T-SQL scripts into a single string and use the code in Listing 5-28 to 
generate a hash of arrays, recording the immediate dependencies among the stored procedures.

=item 3

Use the mapping obtained in step 1 to convert the hash of arrays to record the immediate 
dependencies among the script files.

=item 4

Use the function I<sortObjs()> in Listing 5-25 to sort the script files.

=back

Given the functions and the scripts introduced previously, now you only need to make 
some minor changes to the code in Listing 5-28 to implement these steps.


=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut

