# This script is for demonstrating various ways you can obtain
# a reference to a Perl variable or value
# It's not really a typical program because it doesn't output anything
# useful or uses the refernces in any way.

$ref1 = \$db;                             # Get reference to a scalar variable
$ref2 = \@databases;                      # Get reference to an array variable
$ref3 = \%dbSize;                         # Get reference to a hash variable
$ref4 = \&getSize;                        # Get reference to a subroutine (i.e. function)
$ref5 = \0.25;                            # Get reference to an anonymous scalar
$ref6 = [ 'master', 'tempdb', 'pubs' ];   # Get reference to an anonymous array
$ref7 = { master => 12, tempdb => 20 };   # Get reference to an anonymous hash
$ref8 = sub { return shift() + 3; };      # Get reference to an anonymous subroutine
