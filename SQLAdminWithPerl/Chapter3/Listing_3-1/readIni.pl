# This script shows how to read the entries from an INI file.
# The dbaReadINI() function is defined inside this script.
# You can also import the function from the SQLDBA::Utility
# module.

use strict;
use Data::Dumper;

# if you want to import the dbaReadINI() function from
# the SQLDBA::Utility module, uncomment the following 
# line
# use SQLDBA:Utility qw( dbaReadINI );

# Read the INI file name from the command line
my $iniFile = shift or
   die "***Err: $0 expects an INI file.";

# Read the config file entries
my $ref = dbaReadINI($iniFile);  

# Dump out what have been read from the INI file
print Dumper($ref);

########################
sub dbaReadINI {
   my ($iniFile) = shift 
      or die "***Err: dbaReadINI() expects an INI file name.\n";
   my ($ref, $section);

   open(INI, "$iniFile") 
      or die "***Err: could not open file $iniFile for read.\n";
   while (<INI>) {
      next if /^\s*\#/;                # skip comment line
      s/^((\\\#|\\\\|[^\#])*).*$/$1/;  # remove trailing comments

      if (/^\s*\[(.+)\]\s*$/) {  # read section heading
         $section = uc($1);      # convert to upper case
         $section =~ s/^\s*//;   # remove leading whitespace
         $section =~ s/\s*$//;   # remove trailing whitespace
         
         die "***Err: $section is a duplicate section heading.\n"
            if exists $ref->{$section};
         $ref->{$section} = {};
         next;
      }

      if ((/^\s*([^=]+)\s*=\s*(.*)\s*$/i) && $section) {
         my ($key, $value) = (uc($1), $2);
         $key =~ s/^\s*//;       # remove leading whitespace
         $key =~ s/\s*$//;       # remove trailing whitespace 
         $value =~ s/^\s*//;     # remove leading whitespace
         $value =~ s/\s*$//;     # remove trailing whitespace
         $value = undef if $value =~ /^\s*$/;

         die "***Err: $key has a duplicate in $section.\n"
            if exists $ref->{$section}->{$key};
         $ref->{$section}->{$key} = $value;
         next;
      }
   } # while

   return $ref;
}  # dbaReadINI