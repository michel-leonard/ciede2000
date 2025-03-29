<?php

// This function written in PHP is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
function ciede_2000($l_1, $a_1, $b_1, $l_2, $a_2, $b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	$k_l = $k_c = $k_h = 1.0;
	$n = (hypot($a_1, $b_1) + hypot($a_2, $b_2)) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	$n = 1.0 + 0.5 * (1.0 - sqrt($n / ($n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	$c_1 = hypot($a_1 * $n, $b_1);
	$c_2 = hypot($a_2 * $n, $b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	$h_1 = atan2($b_1, $a_1 * $n);
	$h_2 = atan2($b_2, $a_2 * $n);
	$h_1 += 2.0 * M_PI * ($h_1 < 0.0);
	$h_2 += 2.0 * M_PI * ($h_2 < 0.0);
	$n = abs($h_2 - $h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < $n && $n < M_PI + 1E-14)
		$n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	$h_m = ($h_1 + $h_2) * 0.5;
	$h_d = ($h_2 - $h_1) * 0.5;
	if (M_PI < $n) {
		if (0.0 < $h_d)
			$h_d -= M_PI;
		else
			$h_d += M_PI;
		$h_m += M_PI;
	}
	$p = 36.0 * $h_m - 55.0 * M_PI;
	$n = ($c_1 + $c_2) * 0.5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	$r_t = -2.0 * sqrt($n / ($n + 6103515625.0))
					   * sin(M_PI / 3.0 * exp($p * $p / (-25.0 * M_PI * M_PI)));
	$n = ($l_1 + $l_2) * 0.5;
	$n = ($n - 50.0) * ($n - 50.0);
	// Lightness.
	$l = ($l_2 - $l_1) / ($k_l * (1.0 + 0.015 * $n / sqrt(20.0 + $n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	$t = 1.0	+ 0.24 * sin(2.0 * $h_m + M_PI * 0.5)
			+ 0.32 * sin(3.0 * $h_m + 8.0 * M_PI / 15.0)
			- 0.17 * sin($h_m + M_PI / 3.0)
			- 0.20 * sin(4.0 * $h_m + 3.0 * M_PI / 20.0);
	$n = $c_1 + $c_2;
	// Hue.
	$h = 2.0 * sqrt($c_1 * $c_2) * sin($h_d) / ($k_h * (1.0 + 0.0075 * $n * $t));
	// Chroma.
	$c = ($c_2 - $c_1) / ($k_c * (1.0 + 0.0225 * $n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 31.1623        a1 = -88.885        b1 = 4.4
// L2 = 31.1623        a2 = -89.0          b2 = 4.4
// CIE ΔE2000 = ΔE00 = 0.02306601396

// L1 = 80.7036        a1 = -38.4189       b1 = -127.0881
// L2 = 80.7036        a2 = -37.598        b2 = -127.0881
// CIE ΔE2000 = ΔE00 = 0.24052532817

// L1 = 21.96          a1 = -95.79         b1 = -81.256
// L2 = 21.96          a2 = -97.192        b2 = -79.4
// CIE ΔE2000 = ΔE00 = 0.63326745301

// L1 = 78.6871        a1 = -105.0         b1 = -13.0
// L2 = 83.588         a2 = -105.0         b2 = -13.0
// CIE ΔE2000 = ΔE00 = 3.35145708628

// L1 = 61.0           a1 = -110.0         b1 = 11.292
// L2 = 62.15          a2 = -75.69         b2 = 17.0
// CIE ΔE2000 = ΔE00 = 7.70210786028

// L1 = 77.0           a1 = -122.7045      b1 = 40.1146
// L2 = 86.0           a2 = -95.5          b2 = 15.0
// CIE ΔE2000 = ΔE00 = 10.11019075255

// L1 = 48.0           a1 = -125.89        b1 = 42.7
// L2 = 56.0           a2 = -120.7         b2 = 1.312
// CIE ΔE2000 = ΔE00 = 15.21122601626

// L1 = 45.0           a1 = -111.2921      b1 = -62.54
// L2 = 62.4           a2 = -88.809        b2 = -110.1
// CIE ΔE2000 = ΔE00 = 21.38262858236

// L1 = 6.72           a1 = -37.7          b1 = 111.6946
// L2 = 1.0            a2 = -64.32         b2 = 40.9
// CIE ΔE2000 = ΔE00 = 24.03380275196

// L1 = 79.77          a1 = -40.0          b1 = 49.0
// L2 = 8.0            a2 = -106.0         b2 = -93.197
// CIE ΔE2000 = ΔE00 = 86.23519578686
