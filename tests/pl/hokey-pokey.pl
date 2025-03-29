# This function written in Perl is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use strict;
use warnings;
use Math::Trig qw(pi);

# The classic CIE ΔE implementation, ΔE2000 (ΔE00).
sub ciede_2000 {
	# Working with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	my ($l_1, $a_1, $b_1, $l_2, $a_2, $b_2) = @_;
	my ($k_l, $k_c, $k_h) = (1.0, 1.0, 1.0);
	my $n = (sqrt($a_1 * $a_1 + $b_1 * $b_1) + sqrt($a_2 * $a_2 + $b_2 * $b_2)) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	$n = 1.0 + 0.5 * (1.0 - sqrt($n / ($n + 6103515625.0)));
	my $c_1 = sqrt($a_1 * $a_1 * $n * $n + $b_1 * $b_1);
	my $c_2 = sqrt($a_2 * $a_2 * $n * $n + $b_2 * $b_2);
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	my $h_1 = atan2($b_1, $a_1 * $n);
	my $h_2 = atan2($b_2, $a_2 * $n);
	$h_1 += 2.0 * pi if $h_1 < 0.0;
	$h_2 += 2.0 * pi if $h_2 < 0.0;
	$n = abs($h_2 - $h_1);
	# Cross-implementation consistent rounding.
	$n = pi if pi - 1E-14 < $n && $n < pi + 1E-14;
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	my $h_m = 0.5 * $h_1 + 0.5 * $h_2;
	my $h_d = ($h_2 - $h_1) * 0.5;
	if (pi < $n) {
		$h_d += (0.0 < $h_d) ? -pi : pi;
		$h_m += pi;
	}
	my $p = (36.0 * $h_m - 55.0 * pi);
	$n = ($c_1 + $c_2) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	my $r_t = -2.0 * sqrt($n / ($n + 6103515625.0))
			* sin(pi / 3.0 * exp($p * $p / (-25.0 * pi * pi)));
	$n = ($l_1 + $l_2) * 0.5;
	$n = ($n - 50.0) * ($n - 50.0);
	# Lightness.
	my $l = ($l_2 - $l_1) / ($k_l * (1.0 + 0.015 * $n / sqrt(20.0 + $n)));
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	my $t = 1.0 + 0.24 * sin(2.0 * $h_m + pi / 2.0)
				+ 0.32 * sin(3.0 * $h_m + 8.0 * pi / 15.0)
				- 0.17 * sin($h_m + pi / 3.0)
				- 0.20 * sin(4.0 * $h_m + 3.0 * pi / 20.0);
	$n = $c_1 + $c_2;
	# Hue.
	my $h = 2.0 * sqrt($c_1 * $c_2) * sin($h_d) / ($k_h * (1.0 + 0.0075 * $n * $t));
	# Chroma.
	my $c = ($c_2 - $c_1) / ($k_c * (1.0 + 0.0225 * $n));
	# Returning the square root ensures that the result represents
	# the "true" geometric distance in the color space.
	return sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t);
}

# GitHub Project : https://github.com/michel-leonard/ciede2000
#  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

# L1 = 72.3           a1 = 63.8           b1 = -59.769
# L2 = 72.3           a2 = 63.81          b2 = -59.769
# CIE ΔE2000 = ΔE00 = 0.0033753545

# L1 = 12.3867        a1 = 94.807         b1 = 99.161
# L2 = 12.3867        a2 = 89.828         b2 = 99.161
# CIE ΔE2000 = ΔE00 = 1.61963125778

# L1 = 21.0           a1 = -21.8093       b1 = -63.94
# L2 = 21.0           a2 = -14.29         b2 = -71.3
# CIE ΔE2000 = ΔE00 = 3.521500996

# L1 = 68.4           a1 = -56.7519       b1 = -107.6058
# L2 = 84.3           a2 = -70.32         b2 = -85.0
# CIE ΔE2000 = ΔE00 = 13.14283152855

# L1 = 43.5           a1 = -121.78        b1 = -51.0816
# L2 = 65.5           a2 = -113.552       b2 = -58.7168
# CIE ΔE2000 = ΔE00 = 21.25810576136

# L1 = 90.2           a1 = -93.151        b1 = -9.8689
# L2 = 88.8444        a2 = -81.7509       b2 = 49.9044
# CIE ΔE2000 = ΔE00 = 23.09460928097

# L1 = 1.58           a1 = -67.0          b1 = -122.0
# L2 = 0.76           a2 = -1.93          b2 = -48.185
# CIE ΔE2000 = ΔE00 = 27.09888890788

# L1 = 61.0           a1 = 52.167         b1 = 109.5642
# L2 = 58.9           a2 = -28.387        b2 = -82.0
# CIE ΔE2000 = ΔE00 = 64.64196734381

# L1 = 82.2           a1 = 117.04         b1 = -48.91
# L2 = 41.0           a2 = -7.5687        b2 = -92.394
# CIE ΔE2000 = ΔE00 = 78.13123617447

# L1 = 0.553          a1 = 126.1323       b1 = 33.0
# L2 = 11.0           a2 = -92.9          b2 = 126.95
# CIE ΔE2000 = ΔE00 = 104.83771174697

##########################################################
##########################################################
##########################################################
############				##################
############	     TESTING		##################
############				##################
##########################################################
##########################################################
##########################################################

use Fcntl qw(:flock);
use POSIX qw(floor);
use IO::Handle;

STDOUT->autoflush(1);

sub prepare_values {
	my ($n) = @_;

	printf "prepare_values('./values-pl.txt', %d)", $n;

	open my $fh, '>', './values-pl.txt' or die "Can't open the file: $!";
	$fh->autoflush(1);

	srand(time);
	
	for (my $i = 1; $i <= $n; $i++) {
		my $L1 = rand(100);
		my $a1 = rand(256) - 128;
		my $b1 = rand(256) - 128;
		my $L2 = rand(100);
		my $a2 = rand(256) - 128;
		my $b2 = rand(256) - 128;
		my $delta_e = ciede_2000($L1, $a1, $b1, $L2, $a2, $b2);
		print $fh "$L1,$a1,$b1,$L2,$a2,$b2,$delta_e\n";

		print "." if $i % 1000 == 0;
	}
	close $fh;
}

use Carp;
use File::Basename;

sub compare_values {
	my ($input_string) = @_;
	croak "Error : A parameter is required" unless defined $input_string;

	my $filename = "./../$input_string/values-$input_string.txt";
	
	printf "compare_values('%s')", $filename;

	open my $fh, '<', $filename or die "Can't open the file '$filename' : $!";

	my $error_count = 0;
	my $line_count	= 0;

	while (my $line = <$fh>) {
		chomp $line;
		$line_count++;

		print "." if $line_count % 1000 == 0;

		my @values = split /,/, $line;

		unless (scalar @values == 7) {
			warn "Error at line $line_count : exactly 7 values are expected\n";
			next;
		}

		my @float_values = map { $_ + 0.0 } @values;

		my $expected = $float_values[6];

		my $delta_e = ciede_2000(@float_values);

		if (abs($delta_e - $expected) > 1e-10) {
			warn "Error : line $line_count - delta_e expected is $expected, computed is $delta_e\n";
			$error_count++;
		}

		last if $error_count >= 10;
	}

	close $fh;
}

if (defined $ARGV[0]) {
	my $input = $ARGV[0];

	if ($input =~ /^[a-zA-Z]+$/) {
		my $lowercase_input = lc($input);
		compare_values($lowercase_input);
		exit 0 ;
	} elsif ($input =~ /^\d+$/ && $input <= 10_000_000) {
		prepare_values($input + 0);
		exit 0 ;
	}
}

print "A single argument is required to test the ΔE2000 (ΔE00) function.\n"
