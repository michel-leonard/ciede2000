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

#
# More samples for the CIEDE2000 color difference formula implementation at https:#bit.ly/ciede2000-samples
#
# Testing lab(68.8, 31.7, 61.68) vs lab(68.8, 31.7, 61.68) expects ΔE2000 = ΔE00 = 0.0
# Testing lab(73.4489, 2.624, -80.948) vs lab(73.4489, 2.624, -81.0) expects ΔE2000 = ΔE00 = 0.01199644243
# Testing lab(88.8152, 126.103, -58.983) vs lab(88.8152, 125.91, -58.983) expects ΔE2000 = ΔE00 = 0.03209189129
# Testing lab(28.1, -24.1, -63.8) vs lab(28.1, -24.1, -64.064) expects ΔE2000 = ΔE00 = 0.05910096658
# Testing lab(35.0, -74.6503, -108.563) vs lab(35.1, -74.6503, -108.563) expects ΔE2000 = ΔE00 = 0.08231513909
# Testing lab(9.0, 4.4, 97.9904) vs lab(9.0, 4.4, 99.0) expects ΔE2000 = ΔE00 = 0.18703973501
# Testing lab(34.1, 15.34, -69.673) vs lab(34.72, 15.34, -69.673) expects ΔE2000 = ΔE00 = 0.50621159851
# Testing lab(30.33, 86.07, 110.0) vs lab(31.0, 86.07, 108.3) expects ΔE2000 = ΔE00 = 0.71295691566
# Testing lab(34.0, -13.723, -122.0462) vs lab(34.0, -10.9932, -122.0462) expects ΔE2000 = ΔE00 = 1.04546862433
# Testing lab(8.36, 123.13, 92.89) vs lab(8.36, 123.13, 89.0) expects ΔE2000 = ΔE00 = 1.19607699383
# Testing lab(46.61, -10.9, -97.151) vs lab(46.61, -6.687, -103.2) expects ΔE2000 = ΔE00 = 1.38274601092
# Testing lab(104.4427, -85.0, 100.0) vs lab(104.4427, -92.9713, 100.0) expects ΔE2000 = ΔE00 = 1.81795930601
# Testing lab(85.04, -51.503, 23.2) vs lab(85.04, -56.0, 28.216) expects ΔE2000 = ΔE00 = 2.06083109438
# Testing lab(42.0, -39.47, -31.49) vs lab(42.0, -39.47, -37.2552) expects ΔE2000 = ΔE00 = 2.32242738733
# Testing lab(56.529, -46.0, -57.73) vs lab(56.901, -39.0, -57.73) expects ΔE2000 = ΔE00 = 2.39806726715
# Testing lab(30.206, -50.4012, 6.1355) vs lab(30.206, -59.776, 6.1355) expects ΔE2000 = ΔE00 = 2.7240290859
# Testing lab(70.0044, 28.13, -13.0) vs lab(70.0044, 28.13, -8.0) expects ΔE2000 = ΔE00 = 2.89547379255
# Testing lab(13.1718, 92.99, -47.1726) vs lab(18.0, 92.99, -47.1726) expects ΔE2000 = ΔE00 = 3.19344984117
# Testing lab(10.12, -45.0558, 14.3) vs lab(15.09, -45.0558, 17.0) expects ΔE2000 = ΔE00 = 3.47496337913
# Testing lab(2.04, 39.885, 96.0001) vs lab(2.04, 32.11, 95.285) expects ΔE2000 = ΔE00 = 3.74387063768
# Testing lab(85.916, 6.0, 73.9) vs lab(85.916, -0.484, 73.9) expects ΔE2000 = ΔE00 = 3.87763601902
# Testing lab(63.0023, 20.0, -83.721) vs lab(66.8, 20.0, -93.06) expects ΔE2000 = ΔE00 = 4.31234276522
# Testing lab(45.9, -126.2, 58.56) vs lab(50.272, -126.2, 55.75) expects ΔE2000 = ΔE00 = 4.37977198118
# Testing lab(120.6, 67.595, 48.0) vs lab(127.2, 67.595, 56.58) expects ΔE2000 = ΔE00 = 4.82643694592
# Testing lab(113.0, -8.521, -38.0464) vs lab(112.7, -16.4175, -43.302) expects ΔE2000 = ΔE00 = 5.02928774761
# Testing lab(17.37, 114.9, -22.7699) vs lab(21.09, 116.0, -5.1136) expects ΔE2000 = ΔE00 = 5.70475201263
# Testing lab(82.6, -55.0, -30.7511) vs lab(80.0, -75.61, -47.075) expects ΔE2000 = ΔE00 = 6.32496865878
# Testing lab(100.39, -118.57, -54.0) vs lab(95.066, -104.3, -72.0) expects ΔE2000 = ΔE00 = 7.52227276077
# Testing lab(45.445, 84.628, 109.4) vs lab(42.0, 117.0, 121.3) expects ΔE2000 = ΔE00 = 8.28870814997
# Testing lab(93.7, -30.804, 40.3978) vs lab(109.87, -39.0, 46.9) expects ΔE2000 = ΔE00 = 9.63467721686
# Testing lab(123.0, 98.34, 39.4355) vs lab(114.2, 66.0, 14.41) expects ΔE2000 = ΔE00 = 10.82655645796
# Testing lab(81.4, 55.5, 63.9) vs lab(68.414, 37.2159, 54.0) expects ΔE2000 = ΔE00 = 11.50485227466
# Testing lab(19.975, 97.9434, -100.0) vs lab(6.481, 56.0, -71.21) expects ΔE2000 = ΔE00 = 12.5654122779
# Testing lab(20.871, 54.0, 32.0) vs lab(18.466, 67.5951, 8.9079) expects ΔE2000 = ΔE00 = 13.60173870607
# Testing lab(104.22, -68.673, 47.5) vs lab(82.0, -101.0, 59.4799) expects ΔE2000 = ΔE00 = 15.02268848663
# Testing lab(96.0393, -72.8, -0.14) vs lab(122.537, -92.33, 13.8) expects ΔE2000 = ΔE00 = 15.67150076127
# Testing lab(97.168, 18.83, -66.501) vs lab(124.0982, -8.09, -32.0) expects ΔE2000 = ΔE00 = 16.73938080381
# Testing lab(106.54, -106.0, 66.695) vs lab(79.0, -87.981, 50.944) expects ΔE2000 = ΔE00 = 17.29454469889
# Testing lab(33.651, -78.372, 70.689) vs lab(11.302, -38.76, 55.254) expects ΔE2000 = ΔE00 = 19.04568979077
# Testing lab(127.848, -83.1814, 60.0) vs lab(104.89, -89.0, 13.0) expects ΔE2000 = ΔE00 = 19.79352063552
# Testing lab(77.9, 119.1, -85.8043) vs lab(108.2998, 127.0, -127.3) expects ΔE2000 = ΔE00 = 20.49408851395
# Testing lab(80.0, 111.2, -49.1) vs lab(57.0, 108.8514, -4.4) expects ΔE2000 = ΔE00 = 21.97987691506
# Testing lab(116.792, 62.0, -6.0) vs lab(86.5, 56.016, -41.68) expects ΔE2000 = ΔE00 = 22.65807761353
# Testing lab(90.22, 86.516, 48.328) vs lab(117.6, 28.9, 31.9155) expects ΔE2000 = ΔE00 = 23.47669645731
# Testing lab(100.5443, -76.593, 98.008) vs lab(90.0, -89.13, 18.02) expects ΔE2000 = ΔE00 = 24.36773576669
# Testing lab(57.6726, -26.7, -126.3) vs lab(88.89, -35.7, -66.24) expects ΔE2000 = ΔE00 = 25.49940582851
# Testing lab(44.0, 2.0, 88.162) vs lab(123.8396, 31.0, 34.8891) expects ΔE2000 = ΔE00 = 60.74253483449
# Testing lab(38.9364, -18.5, -64.7194) vs lab(122.3013, -50.181, 54.0) expects ΔE2000 = ΔE00 = 83.65902437262
# Testing lab(79.601, -122.0, -40.0) vs lab(15.0457, 77.348, -16.6) expects ΔE2000 = ΔE00 = 123.35005156744
# Testing lab(12.14, 126.95, -63.838) vs lab(99.0, -67.68, 66.3) expects ΔE2000 = ΔE00 = 135.41043955769
