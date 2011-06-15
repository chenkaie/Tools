#!/usr/bin/perl

# Win32-Exe module: http://search.cpan.org/~autrijus/Win32-Exe-0.08/lib/Win32/Exe.pm

use lib '/home/kent/perl5/lib/perl5/';
use Win32::Exe;

$target = shift(@ARGV);
if (!$target)
{
	print "Usage: get_dll_version.pl *.dll \n";
	exit 1;
}
#print $target, "\n";

my $exe = Win32::Exe->new($target);

# Get version information
print $exe->version_info->get('ProductVersion'), "\n";
#print $exe->version_info->get('FileVersion'), "\n";

