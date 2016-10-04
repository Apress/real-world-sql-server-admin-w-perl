# Use the module Win32:File. Its function GetAttributes() is not
# imported explicitly. The module doesn't export the function
# automatically

use Win32::File;

# Since the function GetAttributes() is not imported, it must be 
# fully qualified whe you use it.

Win32::File::GetAttributes('junk.txt', $a) or die $!;
Win32::File::SetAttributes('junk.txt', READONLY | $a ) or die $!;

