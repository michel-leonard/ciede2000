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
	my $h_m = ($h_1 + $h_2) * 0.5;
	my $h_d = ($h_2 - $h_1) * 0.5;
	if (pi < $n) {
		$h_d += (0.0 < $h_d) ? -pi : pi;
		$h_m += pi;
	}
	my $p = 36.0 * $h_m - 55.0 * pi;
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
	my $t = 1.0	+ 0.24 * sin(2.0 * $h_m + pi * 0.5)
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

# L1 = 84.0           a1 = 51.36          b1 = -103.0
# L2 = 84.0           a2 = 51.351         b2 = -103.0
# CIE ΔE2000 = ΔE00 = 0.00448603525

# L1 = 50.0           a1 = -105.0         b1 = 120.7316
# L2 = 50.0           a2 = -105.0         b2 = 120.37
# CIE ΔE2000 = ΔE00 = 0.06698262779

# L1 = 44.0           a1 = 91.139         b1 = 66.3986
# L2 = 44.0           a2 = 91.139         b2 = 62.1
# CIE ΔE2000 = ΔE00 = 1.61020470894

# L1 = 42.0           a1 = -36.79         b1 = 40.377
# L2 = 42.0           a2 = -44.07         b2 = 40.377
# CIE ΔE2000 = ΔE00 = 2.79959891991

# L1 = 35.7           a1 = -97.48         b1 = -88.1
# L2 = 39.9           a2 = -79.4543       b2 = -61.569
# CIE ΔE2000 = ΔE00 = 6.60080034294

# L1 = 9.97           a1 = -127.3         b1 = -82.4
# L2 = 20.982         a2 = -95.87         b2 = -80.254
# CIE ΔE2000 = ΔE00 = 9.2891401639

# L1 = 70.55          a1 = 114.4355       b1 = -77.0457
# L2 = 81.993         a2 = 119.0          b2 = -52.55
# CIE ΔE2000 = ΔE00 = 10.60509231724

# L1 = 24.0           a1 = -35.93         b1 = -105.0
# L2 = 37.31          a2 = -36.0          b2 = -65.1111
# CIE ΔE2000 = ΔE00 = 12.85377389046

# L1 = 91.695         a1 = 127.0          b1 = 49.36
# L2 = 98.1           a2 = 57.0           b2 = 23.14
# CIE ΔE2000 = ΔE00 = 14.25130084469

# L1 = 97.0           a1 = -81.1263       b1 = -84.34
# L2 = 24.17          a2 = 73.934         b2 = 14.487
# CIE ΔE2000 = ΔE00 = 130.55634271853
