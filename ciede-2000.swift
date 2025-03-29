// This function written in Swift is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import Foundation

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
func ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double) -> Double {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	let k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	let c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	if h_1 < 0.0 { h_1 += 2.0 * .pi; }
	if h_2 < 0.0 { h_2 += 2.0 * .pi; }
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if .pi - 1E-14 < n && n < .pi + 1E-14 { n = .pi; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if .pi < n {
		if 0.0 < h_d { h_d -= .pi; }
		else { h_d += .pi; }
		h_m += .pi;
	}
	let p = 36.0 * h_m - 55.0 * .pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -2.0 * sqrt(n / (n + 6103515625.0))
			* sin(.pi / 3.0 * exp(p * p / (-25.0 * .pi * .pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0 	+ 0.24 * sin(2.0 * h_m + .pi * 0.5)
			+ 0.32 * sin(3.0 * h_m + 8.0 * .pi / 15.0)
			- 0.17 * sin(h_m + .pi / 3.0)
			- 0.20 * sin(4.0 * h_m + 3.0 * .pi / 20.0);
	n = c_1 + c_2;
	// Hue.
	let h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 41.922         a1 = -105.598       b1 = -94.0281
// L2 = 41.922         a2 = -105.6         b2 = -94.0281
// CIE ΔE2000 = ΔE00 = 0.00038591345

// L1 = 81.059         a1 = 55.2256        b1 = 53.9404
// L2 = 82.0           a2 = 54.007         b2 = 53.5871
// CIE ΔE2000 = ΔE00 = 0.76696050549

// L1 = 76.57          a1 = -25.89         b1 = 96.846
// L2 = 76.57          a2 = -25.89         b2 = 92.1584
// CIE ΔE2000 = ΔE00 = 1.01070350217

// L1 = 76.0           a1 = 45.82          b1 = 96.0453
// L2 = 76.0           a2 = 46.634         b2 = 101.2821
// CIE ΔE2000 = ΔE00 = 1.14262228008

// L1 = 51.0           a1 = -123.0         b1 = -65.0
// L2 = 53.139         a2 = -123.0         b2 = -65.0
// CIE ΔE2000 = ΔE00 = 2.11147305518

// L1 = 16.1473        a1 = 83.783         b1 = -71.67
// L2 = 17.6053        a2 = 93.71          b2 = -71.67
// CIE ΔE2000 = ΔE00 = 2.72681219993

// L1 = 9.0            a1 = 81.906         b1 = -47.9
// L2 = 13.0           a2 = 91.8           b2 = -47.9
// CIE ΔE2000 = ΔE00 = 3.39949391914

// L1 = 29.119         a1 = -83.7622       b1 = 5.0
// L2 = 35.771         a2 = -105.0         b2 = 21.0
// CIE ΔE2000 = ΔE00 = 8.59131365666

// L1 = 24.7003        a1 = -78.6319       b1 = -90.0
// L2 = 6.0            a2 = -47.0          b2 = -52.22
// CIE ΔE2000 = ΔE00 = 15.4773562258

// L1 = 84.1           a1 = -78.715        b1 = 29.0
// L2 = 83.0           a2 = -23.3179       b2 = 57.0
// CIE ΔE2000 = ΔE00 = 24.04645456747
