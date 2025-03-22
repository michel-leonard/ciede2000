<?php

// This function written in PHP is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
function ciede_2000($L1, $a1, $b1, $L2, $a2, $b2) {
	// Working with the CIEDE2000 color-difference formula.
	// kL, kC, kH are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	$kL = $kC = $kH = 1.0;
	$n = (hypot($a1, $b1) + hypot($a2, $b2)) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	$n = 1.0 + 0.5 * (1.0 - sqrt($n / ($n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	$c_1 = hypot($a1 * $n, $b1);
	$c_2 = hypot($a2 * $n, $b2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	$h_1 = atan2($b1, $a1 * $n);
	$h_2 = atan2($b2, $a2 * $n);
	$h_1 += 2.0 * M_PI * ($h_1 < 0.0);
	$h_2 += 2.0 * M_PI * ($h_2 < 0.0);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next line handle this issue.
	$h_tmp = ($h_1 + $h_2) * 0.5 + M_PI * (M_PI < abs($h_1 - $h_2));
	$n = ($c_1 + $c_2) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	$p = (36.0 * $h_tmp - 55.0 * M_PI);
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	$r_t = -2.0	* sqrt($n / ($n + 6103515625.0))
			* sin(M_PI / 3.0 * exp($p * $p / (-25.0 * M_PI * M_PI)));
	$n = ($L1 + $L2) * 0.5;
	$n = ($n - 50.0) * ($n - 50.0);
	// Lightness
	$l = ($L2 - $L1) / ($kL * (1.0 + 0.015 * $n / sqrt(20.0 + $n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	$t = 1.0	+ 0.24 * sin(2.0 * $h_tmp + M_PI_2)
			+ 0.32 * sin(3.0 * $h_tmp + 8.0 * M_PI / 15.0)
			- 0.17 * sin($h_tmp + M_PI / 3.0)
			- 0.20 * sin(4.0 * $h_tmp + 3.0 * M_PI_2 / 10.0);
	$n = $c_1 + $c_2;
	$h_tmp = ($h_2 - $h_1) * 0.5;
	$h_tmp += M_PI * ($h_tmp < -M_PI_2);
	$h_tmp -= M_PI * (M_PI_2 < $h_tmp);
	// Hue
	$h = 2.0 * sqrt($c_1 * $c_2) * sin($h_tmp) / ($kH * (1.0 + 0.0075 * $n * $t));
	// Chroma
	$c = ($c_2 - $c_1) / ($kC * (1 + 0.0225 * $n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t);
}

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(76.844, -14.388, 40.4585) vs lab(76.844, -14.388, 40.4585) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(54.844, -119.8, 111.0) vs lab(54.844, -119.8, 111.123) expects ΔE2000 = ΔE00 = 0.02313555897
// Testing lab(27.0, -61.85, 60.535) vs lab(27.0, -61.85, 60.371) expects ΔE2000 = ΔE00 = 0.04876786479
// Testing lab(5.5, 111.6147, -108.0) vs lab(5.5, 111.6147, -107.789) expects ΔE2000 = ΔE00 = 0.05440969008
// Testing lab(47.0, -93.091, -89.2) vs lab(47.0, -92.711, -89.2) expects ΔE2000 = ΔE00 = 0.07958280852
// Testing lab(61.8, 56.71, 41.0) vs lab(61.8, 56.71, 40.71) expects ΔE2000 = ΔE00 = 0.13823262029
// Testing lab(119.0, 29.0, 85.61) vs lab(120.0, 29.0, 85.61) expects ΔE2000 = ΔE00 = 0.4901123735
// Testing lab(89.0, 77.0, 12.39) vs lab(89.9, 75.9, 12.39) expects ΔE2000 = ΔE00 = 0.62086082535
// Testing lab(117.264, 107.3, -92.0) vs lab(117.264, 111.1, -92.0) expects ΔE2000 = ΔE00 = 0.85920944045
// Testing lab(47.09, -72.753, 70.8246) vs lab(47.09, -72.753, 75.1226) expects ΔE2000 = ΔE00 = 1.12797574463
// Testing lab(35.8213, -5.8, -113.18) vs lab(35.8213, -9.2132, -113.18) expects ΔE2000 = ΔE00 = 1.42607780642
// Testing lab(125.0, 121.0, 69.811) vs lab(125.0, 118.8, 74.0) expects ΔE2000 = ΔE00 = 1.76960674261
// Testing lab(19.45, 95.3, 110.5) vs lab(22.28, 95.3, 108.834) expects ΔE2000 = ΔE00 = 2.03359458921
// Testing lab(15.2747, -88.0, -46.0) vs lab(15.2747, -88.0, -39.623) expects ΔE2000 = ΔE00 = 2.21543785112
// Testing lab(126.11, -48.51, 80.4) vs lab(126.11, -41.47, 80.4) expects ΔE2000 = ΔE00 = 2.56244534184
// Testing lab(91.6907, 77.0, -59.0) vs lab(91.6907, 77.0, -67.6) expects ΔE2000 = ΔE00 = 2.84932248426
// Testing lab(95.42, 38.0, -1.2629) vs lab(98.3671, 43.502, -3.824) expects ΔE2000 = ΔE00 = 2.90347144498
// Testing lab(45.85, -38.0, 119.7) vs lab(49.1, -38.0, 119.7) expects ΔE2000 = ΔE00 = 3.19058676452
// Testing lab(36.276, 45.4271, -22.9308) vs lab(36.276, 41.0, -28.0) expects ΔE2000 = ΔE00 = 3.41413009713
// Testing lab(103.1, -78.5, -117.7) vs lab(110.0, -78.5, -116.0) expects ΔE2000 = ΔE00 = 3.74894217108
// Testing lab(125.79, 26.8, 67.0) vs lab(133.5308, 26.8, 61.9488) expects ΔE2000 = ΔE00 = 3.89352301119
// Testing lab(5.52, 34.24, 64.27) vs lab(7.189, 42.0, 64.27) expects ΔE2000 = ΔE00 = 4.1744218339
// Testing lab(127.413, 111.3596, -100.5197) vs lab(127.413, 101.4, -109.3501) expects ΔE2000 = ΔE00 = 4.53539868441
// Testing lab(27.0, -15.4, -72.0) vs lab(30.0, -24.707, -69.1719) expects ΔE2000 = ΔE00 = 4.66523571065
// Testing lab(41.7135, 93.95, 8.236) vs lab(46.0, 109.425, 13.0) expects ΔE2000 = ΔE00 = 5.01544767819
// Testing lab(112.6, -112.85, 16.96) vs lab(124.321, -110.4, 16.63) expects ΔE2000 = ΔE00 = 5.80321420993
// Testing lab(84.0, -104.292, 81.7496) vs lab(76.7, -112.0, 105.55) expects ΔE2000 = ΔE00 = 6.66326863289
// Testing lab(98.0, 69.11, -98.46) vs lab(110.0, 84.241, -121.0) expects ΔE2000 = ΔE00 = 7.71613301575
// Testing lab(126.0, 47.2, 65.542) vs lab(124.0, 30.2, 62.5) expects ΔE2000 = ΔE00 = 8.15905991594
// Testing lab(110.8, -100.022, -3.5936) vs lab(116.0, -120.25, 22.0) expects ΔE2000 = ΔE00 = 9.94593509197
// Testing lab(117.1, 28.0, 54.58) vs lab(111.94, 54.67, 93.5) expects ΔE2000 = ΔE00 = 10.40882182343
// Testing lab(92.251, -124.925, -122.3383) vs lab(84.4, -108.29, -65.8848) expects ΔE2000 = ΔE00 = 11.41424538448
// Testing lab(86.343, 77.803, -50.536) vs lab(107.406, 74.2, -43.603) expects ΔE2000 = ΔE00 = 12.55528510533
// Testing lab(94.426, -16.8, -75.0) vs lab(90.0, -53.0, -105.8675) expects ΔE2000 = ΔE00 = 13.1700969699
// Testing lab(31.049, -91.4, 57.5) vs lab(30.0, -74.048, 106.5) expects ΔE2000 = ΔE00 = 14.30590820471
// Testing lab(115.0, 2.4, -26.7) vs lab(114.96, 67.0, -111.605) expects ΔE2000 = ΔE00 = 16.08348293502
// Testing lab(67.4935, 67.22, -82.518) vs lab(77.0, 98.577, -57.7) expects ΔE2000 = ΔE00 = 16.57071380869
// Testing lab(1.2039, -112.677, 89.5092) vs lab(24.0, -76.0, 43.63) expects ΔE2000 = ΔE00 = 17.91366640754
// Testing lab(101.0, 6.97, -30.2091) vs lab(79.657, 30.257, -86.0) expects ΔE2000 = ΔE00 = 18.65098697254
// Testing lab(74.125, -99.0, -60.2546) vs lab(67.8461, -51.0, -110.89) expects ΔE2000 = ΔE00 = 19.12450228953
// Testing lab(88.25, -97.7, -102.0) vs lab(125.935, -103.42, -104.08) expects ΔE2000 = ΔE00 = 20.35192502517
// Testing lab(124.2, -56.8, -87.2) vs lab(89.1, -115.91, -112.0) expects ΔE2000 = ΔE00 = 21.99317447199
// Testing lab(32.0, -59.7704, 60.0) vs lab(2.0, -41.4871, 75.3408) expects ΔE2000 = ΔE00 = 22.17460912079
// Testing lab(103.8, 53.0, 101.8) vs lab(77.4476, 12.97, 51.913) expects ΔE2000 = ΔE00 = 23.3352467278
// Testing lab(85.98, 126.3, 66.5301) vs lab(57.0, 118.482, 34.153) expects ΔE2000 = ΔE00 = 24.15637515461
// Testing lab(61.3625, -77.54, -84.8437) vs lab(100.242, -122.26, -101.2852) expects ΔE2000 = ΔE00 = 27.77670386286
// Testing lab(92.9, -115.4111, 10.3015) vs lab(71.472, 42.4, -114.0087) expects ΔE2000 = ΔE00 = 54.79818740897
// Testing lab(124.279, 105.362, -66.6) vs lab(42.0, 31.85, 93.0) expects ΔE2000 = ΔE00 = 86.44280474288
// Testing lab(53.59, 118.2, -52.575) vs lab(8.802, -53.09, 69.0) expects ΔE2000 = ΔE00 = 106.74910649823
// Testing lab(119.294, 88.7558, 116.97) vs lab(2.7646, -123.46, 34.6087) expects ΔE2000 = ΔE00 = 129.98829153146

