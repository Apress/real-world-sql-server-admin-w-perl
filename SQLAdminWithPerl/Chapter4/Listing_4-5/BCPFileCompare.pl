use strict;
use File::Compare;
use SQLDBA::Utility qw( dbaSetDiff dbaSetCommon );
use Getopt::Std;

my %opts;
getopts('i:o:t', \%opts);
my ($indir, $outdir, $textmode) = ($opts{i}, $opts{o}, $opts{t});

(defined $indir && defined $outdir) or printUsage();

# get the list of files in indir
opendir(DIR, "$indir") or die "***Err: can't opendir $indir: $!";
my @infiles = grep {!/^(\.|\.\.)$/} readdir(DIR);
closedir DIR;

# get the list of files in outdir
opendir(DIR, "$outdir") or die "***Err: can't opendir $outdir: $!";
my @outfiles = grep {!/^(\.|\.\.)$/} readdir(DIR);
closedir DIR;

my @diff = ();
my $unequal = 0;

if (@diff = dbaSetDiff(\@infiles, \@outfiles)) {
    print "***Msg: these files in $indir do not exist in $outdir:\n";
    map {print "\t$_\n"} @diff;
    $unequal = 1;    
}

if (@diff = dbaSetDiff(\@outfiles, \@infiles)) {
    print "***Msg: these files in $outdir do not exist in $indir:\n";
    map {print "\t$_\n"} @diff;
    $unequal = 1;
}

print "\nNow we compare files in both directories:\n\n";
foreach my $file (dbaSetCommon(\@infiles, \@outfiles)) {
    my $f_in = "$indir\\$file";
    my $f_out = "$outdir\\$file";
    print "\tComparing $file ...\n";

    if ($textmode) 
       { $unequal = File::Compare::compare_text($f_in, $f_out); }
    else 
       { $unequal = compare($f_in, $f_out); }
    push(@diff, $file) if ($unequal);
}

if (@diff) {
    print "\n***Msg: these files are different:\n";
    map {print "\t$_\n"} @diff;
}
else {
    print "\n*** All the common files are identical.\n";
}

############################
sub printUsage {
    print << '--Usage--';
Usage:    
   cmd>perl BCPFileCompare.pl -i <bcp in directory> -o <bcp out directory> [-t]
--Usage--
exit;
} # printUsage


__END__

=head1 NAME

BCPFileCompare - Compare bcp files in two directories

=head1 SYNOPSIS

 cmd>perl BCPFileCompare.pl -i <Dir Name1> -o <Dir Name2> [-t]

=head1 DESCRIPTION

This script was written to compare the data files used by the SQL Server bulk copy program. 
This script helps us gain confidence that we have correctly bulk copied all the data into the server.

The data files that are to be bulk cppied into SQL Server should be placed in a directory 
specified with the -i option. After the data have been bulk cpoed into their corresponding tables,
you then bulk copy them out to a different directory, specified with the -o option, using the same file names for the corresponding tables. 
This script then can be used to compare the files in the two directories.

The comparison is conducted in two steps:

=over

=item Step 1

The script compares the file names to see whether a file is only present in one directory, but 
the other one.

=item Step 2

For the files common in both directories, the script then compares the content of each file. If 
the -t option is specified, the script treats the files as text files. The option -t should be specified
if bcp is performed using the character mode, i.e. -c is used.

=back

=head1 AUTHOR

Linchi Shea

=head1 VERSION

 2002.01.14

=cut
