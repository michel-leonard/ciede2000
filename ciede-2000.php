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
