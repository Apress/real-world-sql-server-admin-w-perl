# See the embedded POD or the HTML documentation

use strict;
use Getopt::Std;
use SQLDBA::SQLDMO qw( dbaGetReferencedTables );
use SQLDBA::Utility qw( dbaRemoveDuplicates );

my %opts;
getopts('S:D:T:', \%opts);             # command line switches
my $tabRef = { srvName => $opts{S},    # server name
               dbName  => $opts{D},    # database name   
               tbName  => $opts{T} };  # table name

my $ref = getRefTree($tabRef);

print "Table reference tree for: $opts{T}\n";
printTree($opts{T}, $ref, 0);

####################
sub getRefTree {
    my $tabRef = shift;

    my %tabTree;
    my $ref = dbaGetReferencedTables($tabRef);
    $ref = dbaRemoveDuplicates($ref);
    foreach my $childTab (@$ref) {
       my $childTabRef = {
              srvName => $tabRef->{srvName},
              dbName  => $tabRef->{dbName},
              tbName  => $childTab
          };
       my $childTree = getRefTree($childTabRef);
       $tabTree{$childTab} = $childTree;
    }
    return \%tabTree;
}

#####################
sub printTree {
   my ($root, $ref, $level) = @_;
   my $indent = 6;
   
   foreach my $node (keys %$ref) {
      print ' ' x (($level + 1) * $indent), " --> $node\n";
      printTree($node, $ref->{$node}, $level + 1);
   }
}


__END__

=head1 NAME

tableTree - Produce a reference tree for a tree

=head1 SYNOPSIS

  cmd>perl tableTree.pl -S <server name> -D <database name> -T <table name>
    
  Options:
     -S    the name of the SQL Server instance
     -D    the name of the database where the table is created
     -T    the name of the table

=head1 SAMPLE OUTPUT

This example shows the reference tree for the table pubs.dbo.titleauthor in the instance APOLLO
on the local server.

 cmd>perl tableTree.pl -S .\APOLLO -D pubs -T dbo.titleauthor 
 Table reference tree for: dbo.titleauthor
       --> [dbo].[titles]
             --> [dbo].[publishers]
                   --> [dbo].[countries]
       --> [dbo].[authors]


=head1 DESCRIPTION

This script allows you to find all the tables that depend on a given table through the
foreign key constraints. This produces a tree-like structure with the given table as the root of the
tree. The leaves of the tree are the tables that don't have any foreign keys.

The core of this script is a recusive function I<getRefTree()>. For a given table, this function loops
through all the child tables and apply the function itself to each of the child tables. When they return
with a table reference tree for each, the function assembles then into the final tree for the table
specified on the command line.

The foreign key information for a given table is retrieved with the function I<dbaGetReferencedTables()>, 
which is imported from the module SQLDBA::SQLDMO. More specifically, the function 
I<dbaGetReferencedTables()> retrieves the names of the tables referenced through foreign keys.

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut

