// This function written in Dart is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import 'dart:math';

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
double ciede_2000(double l_1, double a_1, double b_1, double l_2, double a_2, double b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Since hypot is not available, sqrt is used here to calculate the
	// Euclidean distance, without avoiding overflow/underflow.
	final double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	final double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0) h_1 += 2.0 * pi;
	if (h_2 < 0.0) h_2 += 2.0 * pi;
	n = (h_2 - h_1).abs();
	// Cross-implementation consistent rounding.
	if (pi - 1E-14 < n && n < pi + 1E-14) n = pi;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (pi < n) {
		if (0.0 < h_d) h_d -= pi;
		else h_d += pi;
		h_m += pi;
	}
	final double p = 36.0 * h_m - 55.0 * pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	final double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	final double t = 1.0 	+ 0.24 * sin(2.0 * h_m + pi * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0)
				- 0.17 * sin(h_m + pi / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
	n = c_1 + c_2;
	// Hue.
	final double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 99.0393        a1 = 47.0           b1 = 22.7
// L2 = 99.0393        a2 = 47.0           b2 = 22.668
// CIE ΔE2000 = ΔE00 = 0.01767670971

// L1 = 10.296         a1 = 60.66          b1 = -68.0
// L2 = 10.296         a2 = 63.67          b2 = -68.0
// CIE ΔE2000 = ΔE00 = 1.10685714591

// L1 = 47.5614        a1 = -92.1          b1 = 107.9
// L2 = 47.5614        a2 = -92.1          b2 = 98.6
// CIE ΔE2000 = ΔE00 = 1.93272160082

// L1 = 25.0           a1 = -22.105        b1 = -47.6868
// L2 = 25.0           a2 = -28.0          b2 = -47.6868
// CIE ΔE2000 = ΔE00 = 2.61667297106

// L1 = 19.6723        a1 = 113.47         b1 = -88.0
// L2 = 16.22          a2 = 83.0           b2 = -68.399
// CIE ΔE2000 = ΔE00 = 5.99423684164

// L1 = 90.0           a1 = -70.3684       b1 = -16.034
// L2 = 88.3           a2 = -82.0          b2 = -2.299
// CIE ΔE2000 = ΔE00 = 7.61921014108

// L1 = 80.4           a1 = 44.8           b1 = -122.526
// L2 = 98.5           a2 = 55.6842        b2 = -119.5
// CIE ΔE2000 = ΔE00 = 13.06695717767

// L1 = 27.3378        a1 = 69.53          b1 = -53.0
// L2 = 41.0587        a2 = 123.1          b2 = -95.39
// CIE ΔE2000 = ΔE00 = 15.37983205376

// L1 = 81.0           a1 = -53.6844       b1 = -68.5
// L2 = 18.0           a2 = -43.1          b2 = -66.663
// CIE ΔE2000 = ΔE00 = 63.02460377305

// L1 = 84.0           a1 = 35.026         b1 = 70.795
// L2 = 25.47          a2 = -6.036         b2 = -74.043
// CIE ΔE2000 = ΔE00 = 79.35408889842
