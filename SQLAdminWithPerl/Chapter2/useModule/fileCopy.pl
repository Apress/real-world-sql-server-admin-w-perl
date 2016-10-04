# Use the module File::Copy and explicitly import
# the function copy()

use File::Copy qw( copy );

# Now that the function copy() has been imported, it
# can be used as if it were a built-in function.

copy('errors.log', 'errors1.log') or die $!;
