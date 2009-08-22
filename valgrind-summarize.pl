#!/usr/bin/perl -w
# ---------------------------------------------------------------------------
# valgrind-summarize.pl - Summarize valgrind output in easy-parse manner.
# Copyright (c) 2007-2009, Jeff Hung
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
#  - Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#  - Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#  - Neither the name of the copyright holders nor the names of its
#    contributors may be used to endorse or promote products derived
#    from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# ----------------------------------------------------------------------------

use strict;
use utf8;
use File::Basename;
use Getopt::Long;

my ($__exe_name__) = (basename($0));
my ($__revision__) = ('$Rev: 470 $' =~ m/(\d+)/o);
my ($__rev_date__) = ('$Date: 2009-05-09 01:32:22 +0800 (Sat, 09 May 2009) $' =~ m/(\d{4}-\d{2}-\d{2})/o);

sub usage
{
	print STDERR <<"EOF";
Usage: $__exe_name__ [ <option> ... ] [ <valgrind-log> ]

Parse valgrind(1) log file <valgrind-log> and report its summary.

Options:

  -h,--help     Show this help message.
  -x,--xml      Output as XML, for easy machine processing.
  -v,--verbose  Show verbose progress messages.

Revision: r$__revision__ ($__rev_date__)
EOF
	exit(0);
}

sub msg_exit
{
	my $ex = ((scalar(@_) > 0) ? shift @_ : 0);
	foreach my $m (@_) {
		print STDERR "ERROR: $m\n";
	}
	print STDERR <<"EOF";
Usage: $__exe_name__ [ <option> ... ] <wp-dump-file> <docbook-file>
Type '$__exe_name__ --help' for usage.
EOF
	exit($ex);
}

my $opt_verbose = 0;
my $opt_output_xml = 0;
if (!GetOptions('h|help'    => sub { usage; },
                'x|xml'     => \$opt_output_xml,
                'v|verbose' => \$opt_verbose)) {
	msg_exit(0);
}
my $arg_valgrind_log = shift @ARGV;

my $valreport = {
	'error_summary' => {},
	'leak_summary'  => {
		'definitely_lost' => { 'bytes' => 0, 'blocks' => 0 },
		'possibly_lost'   => { 'bytes' => 0, 'blocks' => 0 },
		'still_reachable' => { 'bytes' => 0, 'blocks' => 0 },
		'suppressed'      => { 'bytes' => 0, 'blocks' => 0 },
		# summary of 'definitely_lost', possibly_lost, and still_reachable.
		# (not including 'suppressed')
		'unwanted_lost'   => { 'bytes' => 0, 'blocks' => 0 },
	},
};

my $valgrind_log_fh = \*STDIN;
if (defined($arg_valgrind_log)) {
	open($valgrind_log_fh, '<', $arg_valgrind_log)
		or die "Cannot open '$arg_valgrind_log': $!";
}
while (my $line = <$valgrind_log_fh>) {
	chomp($line);
	$line =~ m/^[=-]+(\d+)[=-]+ /o;
	if ($1) {
		$valreport->{'pid'} = $1 unless defined($valreport->{'pid'});
		die "Mismatched PID." unless ($1 == $valreport->{'pid'});
	}

	if ($line =~ m/^==\d+==    definitely lost:\s*(\d+) bytes in (\d+) blocks./o) {
		$valreport->{'leak_summary'}->{'definitely_lost'} = {
			'bytes'  => $1,
			'blocks' => $2,
		};
	}
	if ($line =~ m/^==\d+==    possibly lost:\s*(\d+) bytes in (\d+) blocks./o) {
		$valreport->{'leak_summary'}->{'possibly_lost'} = {
			'bytes'  => $1,
			'blocks' => $2,
		};
	}
	if ($line =~ m/^==\d+==    still reachable:\s*(\d+) bytes in (\d+) blocks./o) {
		$valreport->{'leak_summary'}->{'still_reachable'} = {
			'bytes'  => $1,
			'blocks' => $2,
		};
	}
	if ($line =~ m/^==\d+==         suppressed:\s*(\d+) bytes in (\d+) blocks./o) {
		$valreport->{'leak_summary'}->{'suppressed'} = {
			'bytes'  => $1,
			'blocks' => $2,
		};
	}
}
if (defined($arg_valgrind_log)) {
	close($valgrind_log_fh);
}

$valreport->{'leak_summary'}->{'unwanted_lost'}->{'bytes'}
	= $valreport->{'leak_summary'}->{'definitely_lost'}->{'bytes'}
	+ $valreport->{'leak_summary'}->{'possibly_lost'}->{'bytes'}
	+ $valreport->{'leak_summary'}->{'still_reachable'}->{'bytes'};
$valreport->{'leak_summary'}->{'unwanted_lost'}->{'blocks'}
	= $valreport->{'leak_summary'}->{'definitely_lost'}->{'blocks'}
	+ $valreport->{'leak_summary'}->{'possibly_lost'}->{'blocks'}
	+ $valreport->{'leak_summary'}->{'still_reachable'}->{'blocks'};

die "No PID found" unless (defined($valreport->{'pid'}));

if ($opt_output_xml) {
	print << "EoXML";
<?xml version=\"1.0\"?>
<valgrind-log>
  <leak_summary>
    <definitely_lost>
      <num_bytes>$valreport->{'leak_summary'}->{'definitely_lost'}->{'bytes'}</num_bytes>
      <num_blocks>$valreport->{'leak_summary'}->{'definitely_lost'}->{'blocks'}</num_blocks>
    </definitely_lost>
    <possibly_lost>
      <num_bytes>$valreport->{'leak_summary'}->{'possibly_lost'}->{'bytes'}</num_bytes>
      <num_blocks>$valreport->{'leak_summary'}->{'possibly_lost'}->{'blocks'}</num_blocks>
    </possibly_lost>
    <still_reachable>
      <num_bytes>$valreport->{'leak_summary'}->{'still_reachable'}->{'bytes'}</num_bytes>
      <num_blocks>$valreport->{'leak_summary'}->{'still_reachable'}->{'blocks'}</num_blocks>
    </still_reachable>
    <suppressed>
      <num_bytes>$valreport->{'leak_summary'}->{'suppressed'}->{'bytes'}</num_bytes>
      <num_blocks>$valreport->{'leak_summary'}->{'suppressed'}->{'blocks'}</num_blocks>
    </suppressed>
    <unwanted_lost>
      <num_bytes>$valreport->{'leak_summary'}->{'unwanted_lost'}->{'bytes'}</num_bytes>
      <num_blocks>$valreport->{'leak_summary'}->{'unwanted_lost'}->{'blocks'}</num_blocks>
    </unwanted_lost>
  </leak_summary>
</valgrind-log>
EoXML
}
else {
	print <<"EOF";
PID: $valreport->{'pid'}
leak_summary:definitely_lost:bytes: $valreport->{'leak_summary'}->{'definitely_lost'}->{'bytes'}
leak_summary:definitely_lost:blocks: $valreport->{'leak_summary'}->{'definitely_lost'}->{'blocks'}
leak_summary:possibly_lost:bytes: $valreport->{'leak_summary'}->{'possibly_lost'}->{'bytes'}
leak_summary:possibly_lost:blocks: $valreport->{'leak_summary'}->{'possibly_lost'}->{'blocks'}
leak_summary:still_reachable:bytes: $valreport->{'leak_summary'}->{'still_reachable'}->{'bytes'}
leak_summary:still_reachable:blocks: $valreport->{'leak_summary'}->{'still_reachable'}->{'blocks'}
leak_summary:suppressed:bytes: $valreport->{'leak_summary'}->{'suppressed'}->{'bytes'}
leak_summary:suppressed:blocks: $valreport->{'leak_summary'}->{'suppressed'}->{'blocks'}
leak_summary:unwanted_lost:bytes: $valreport->{'leak_summary'}->{'unwanted_lost'}->{'bytes'}
leak_summary:unwanted_lost:blocks: $valreport->{'leak_summary'}->{'unwanted_lost'}->{'blocks'}
EOF
}

exit (($valreport->{'leak_summary'}->{'unwanted_lost'}->{'bytes'} == 0) ? 0 : 1);


