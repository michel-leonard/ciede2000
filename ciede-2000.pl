# This function written in Perl is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use strict;
use warnings;
use Math::Trig qw(pi);

# Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
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
		$h_d -= pi if $h_d > 0.0;
		$h_d += pi if $h_d <= 0.0;
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
