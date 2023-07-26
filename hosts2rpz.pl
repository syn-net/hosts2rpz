#!/usr/bin/perl
#
# 1. https://github.com/f3sty/hosts2rpz (original version)
# 2. https://github.com/syn-net/hosts2rpz (refactored version)
#
use strict;
use warnings;
use Getopt::Long;
use List::Util qw[min max];
use LWP::UserAgent;
use HTTP::Request;

# default file locations for input and output files
my $in  = '';
my $out = '';

my $verbose = 0;
my $help;

# User-Agent string for http(s) requests
my $script_version = '0.3';
my $agent = "hosts2rpz/${script_version} (https://github.com/syn-net/hosts2rpz))";

# process any args the script was passed
GetOptions(
    'help'     => \$help,
    'verbose+' => \$verbose,
    'in=s'     => \$in,
    'out=s'    => \$out,
);

if ($help) {
    &printhelp;
    exit(0);
}

my %rec;
my $hostname;
my $maxlen = 1;    # length of longest parsed hostname
my $rrformat;
my ( $h, $a );
my $serial = time;
# FIXME(jeff): I have yet to figure out how to insert these two variables
# within a "perlform" [1].
# 1. https://perldoc.perl.org/perlform
# IMPORTANT(jeff): The authoritative hostname must end with a dot (.)
my $soa_hostname = 'rpz.lan.';
# IMPORTANT(jeff): The administrative e-mail address must end with a dot (.)
my $dns_admin_email = 'hostmaster.lan.';

my $ua = LWP::UserAgent->new;
$ua->agent($agent);

my $exit_script_usage = "Usage: $0 --in [infile] --out [outfile]\n\n";

# read the input file
unless ( -f $in ) {
    print $exit_script_usage;
    exit 0;
}

# we must have a file we can output to
unless ( $out ) {
    print $exit_script_usage;
    exit 0;
}

open my $infile, "<${in}"
  or die "Something went wrong trying to read $in\n";
while (<$infile>) {
    chomp;

    # strip comments
    $_ =~ s/(#|\/\/).*//;
    next unless ( $_ =~ m/\w/ );

    # handle multiple hostnames per line
    my @hostsentry = split /\s+/, $_;
    my $ip = shift(@hostsentry);
    foreach $hostname (@hostsentry) {
        $maxlen = max( $maxlen, length($hostname) );
        $rec{$hostname} = $ip;
    }
}

# dynamic template format based on the max hostname length
$rrformat =
    "format RR = \n" . '@'
  . '<' x $maxlen
  . '  IN   CNAME   .' . "\n" . '$h,$a' . "\n" . ".\n";
  #. '  IN   A    @<<<<<<<<<<<<<<' . "\n" . '$h,$a' . "\n" . ".\n";
eval $rrformat;

open my $outfile, ">${out}" or die "Error writing to $out\n\n";

# write out the rpz.db header,
# set the zone serial to POSIX timestamp
select($outfile);
$~ = 'HEADER';
write $outfile;

# write out each RR
foreach $hostname ( sort keys %rec ) {
    &write_rr( $hostname, $rec{$hostname} );
}

close $outfile;
select(STDOUT);

sub printhelp {
    print "\n\nhosts2rpz.pl - convert hosts files to rpz zone format\n";
    print "  Usage: hosts2rpz.pl [-iovuh]\n\n";
    print "   -i | --in       input file\n";
    print "   -o | --out      output file (rpz db)\n";
    print "   -v | --verbose  increase script verbosity\n";
    print "   -h | --help     You are here\n\n";
}

sub write_rr($$) {
    $h = shift;
    $a = shift;
    select($outfile);
    $~ = 'RR';
    write $outfile;
}

# rpz db SOA template
format HEADER =
$TTL 60
@            IN    SOA  rpz.lan. hostmaster.lan.  (
'@'
            @>>>>>>>>>>>>>>>  ; serial:@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                          $serial,$serial
                          3H  ; refresh
                          1H  ; retry
                          1W  ; expiry
                          1H) ; minimum
                  IN    NS    localhost.

.
