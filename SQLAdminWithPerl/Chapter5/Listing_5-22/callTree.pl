# See the embedded POD or the HTML documentation for details

use strict;
use Getopt::Std;
use SQLDBA::SQLDMO qw( dbaScriptSP2 );      # import the function to script SPs
use SQLDBA::ParseSQL qw( dbaNormalizeSQL ); 
use Win32::OLE;
use Data::Dumper;

my %opts;
getopts('S:D:P:', \%opts);          # command line switches
my $ref = { srvName => $opts{S},    # server name
            dbName  => $opts{D},    # database name   
            spName  => $opts{P} };  # stored procedure name

# Connect to the SQL Server via SQL-DMO for scripting purposes       
my $srvObj = Win32::OLE->new('SQLDMO.SQLServer')
      or die "***Err: Could not create SQLDMO object.";
$srvObj->{LoginSecure} = 1;
$srvObj->connect($ref->{srvName}, '', '');
! Win32::OLE->LastError() or
      die "***Err: Could not connect to $ref->{srvName}.";

# This sclar reference will be passed to the function getCallTree()   
my $srvRef = { srvObj => $srvObj,      # Win32::OLE object
               dbName => $ref->{dbName},
               spName => $ref->{spName} };

my $callTree = getCallTree($srvRef);   # get the call tree
$srvObj->Close();

print "Call tree for: $opts{P}\n";
printTree($opts{P}, $callTree, 0);

#####################
# Recursively print the call tree
sub printTree {
   my ($root, $ref, $level) = @_;
   my $indent = 6;
   
   foreach my $node (keys %$ref) {
      print ' ' x (($level + 1) * $indent), " --> $node\n";
      printTree($node, $ref->{$node}, $level + 1);
   }
}

####################
# Look for SPs in the EXECUTE statements
sub findSPCalls {
   my $script = shift or die "***Err: findSPCalls() expects a string.";
   
   my $spRef = dbaNormalizeSQL($script, 0);
   my $owner = 'dbo';  # default SP owner to dbo
   my @calledSPs;
   while ($spRef->{code} =~
                        /(?<![\w\@\#\$])  # negative lookbehind
                          EXEC(UTE)?      # keywords EXECUTE or EXEC
                          \s+(\@.+?=\s*)? # return variable and whitespaces
                          ([^(\s]+)       # proc name
                        /igx) {           # case insensitive and match all
         my $sp = $3;
         # add owner if not specified explicitly
         if ($sp =~ /^[^.]+$/) { $sp = $owner . '.' . $sp; }
         if ($sp =~ /^([^.]+)\.\.([^.]+)$/) {
            $sp = "$1.$owner.$2";
         }
         
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
# Recursively construct the SP call tree
sub getCallTree {
   my $ref = shift or die "***Err: getCallTree() expects a reference.";

   my %callTree;
   my $spRef = dbaScriptSP2($ref) or return \%callTree;
   my @SPs = findSPCalls($spRef->{Script});

   foreach my $sp (@SPs) {
      if ($sp =~ /^\s*([^\s]+)\.([^\s]*\.[^\s]+)/) {
         ($ref->{dbName}, $sp) = ($1, $2);
      }
      # skip the recursion if the SP calls by itself
      next if $sp =~ /^$ref->{spName}$/;
      my $subTree = getCallTree( { srvObj => $ref->{srvObj},
                                   dbName => $ref->{dbName},
                                   spName => $sp } );
      $callTree{$ref->{dbName}. '.' . $sp} = $subTree;  # add to the tree
   }
   return \%callTree;
} # getCallTree


__END__

=head1 NAME

callTree - Produce a call tree for a given stored procedure

=head1 SYNOPSIS

 cmd>perl callTree.pl -S<Server name> -D<Database name> -P<SP Name>

=head1 DESCRIPTION

This script finds the call tree for a given stored procedure. The call tree of a stored procedure
is the tree-like relationship among the stored procedures. Each node of the tree represents a 
stored procedure with I<the> stored procedure at the root of the tree. For any node in the tree, its 
parent is the stored procedure that calls it and its children are the stored procedures that it calls.

Such a call tree describes the dependencies among the stored procedures.

=head1 SAMPLE OUTPUT

The following example shows the call tree when the script I<callTree.pl> is applied to the stored procedure
NYSQL01.pubs.dbo.spCall.

 cmd>perl callTree.pl -S NYSQL01 -D pubs -P dbo.spCall
 Call tree for: spCall
       --> pubs.dbo.spCall2
                    --> pubs.dbo.spCall3
                               --> Northwind.dbo.reptq4
                                         --> Northwind.dbo.reptq5
                    --> pubs.dbo.reptq2
       --> pubs.dbo.reptq1
       --> pubs.dbo.reptq3
 

In this example, the stored procedure spCall calls three stored procedures directly: I<pubs.dbo.spCall2>,
I<pubs.dbo.reptq1>, and I<pubs.dbo.reptq3>. The stored procedure I<pubs.dbo.spCall2> in turns calls two stored
procedures, I<pubs.dbo.spCall3> and I<pubs.dbo.reptq2>. Furthermore, the stored procedure I<pubs.dbo.spCall3>
calls the stored procedure I<Northwind.dbo.reptq4>, which in turn calls I<Northwind.dbo.reptq5>.

=head1 CONSTRUCTING THE CALL TREE

Given a stored procedure, the process to construct its call tree is as follows: 

=over

=item 1

Use I<dbaScriptSP2()> to script out the T-SQL code of the stored procedure.

=item 2

Apply I<findSPCalls()> to find all its immediate child procedures.

=item 3

For each of the child stored procedure, construct its call tree.

=item 4

Put all child call trees together in a hash with the names of the child stored 
procedures as the keys. Return a reference to this hash as the call tree of the 
stored procedure.

=back

Obviously, this process is recursive in nature. The recursion terminates when a 
stored procedure doesn'’t call any other stored procedure. This process is implemented in 
the function I<getCallTree()> shown in Listing 5-20.


=head1 DATA STRUCTURE

For the output shown above, the following data structure stores the call tree:

 $callTreeRef = {  
            'pubs.dbo.reptq3' => { },
            'pubs.dbo.spCall2' => { 
                      'pubs.dbo.reptq2' => { },
                      'pubs.dbo.spCall3' => { 
                                              'Northwind.dbo.reptq4' => {
                                                  'Northwind.dbo.reptq5' => { }
                                              },
                       },
                      'pubs.dbo.reptq1' => { }
   };

Note the beauty of this data structure. This is a nested hash of hashes to an arbitrary number of 
levels.

=head1 NOTE

The I<callTree.pl> script doesn't apply to T-SQL stored procedure recursive calls. In other words, 
if a stored procedure directly or indirectly calls itself, the I<callTree.pl> script will abort.


=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2003.01.27

=cut
