// This function written in C99 is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining pi ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
static double ciede_2000(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const double c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	h_1 += 2.0 * M_PI * (h_1 < 0.0);
	h_2 += 2.0 * M_PI * (h_2 < 0.0);
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
	const double p = 36.0 * h_m - 55.0 * M_PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0 	+ 0.24 * sin(2.0 * h_m + M_PI * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// Compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 58.18          a1 = 77.92          b1 = -17.7
// L2 = 58.18          a2 = 77.86          b2 = -17.7
// CIE ΔE2000 = ΔE00 = 0.01363326143

// L1 = 58.0931        a1 = -15.461        b1 = 109.0
// L2 = 58.0931        a2 = -15.461        b2 = 110.782
// CIE ΔE2000 = ΔE00 = 0.31613362231

// L1 = 96.747         a1 = 60.386         b1 = -109.18
// L2 = 96.747         a2 = 59.5           b2 = -106.76
// CIE ΔE2000 = ΔE00 = 0.51863384056

// L1 = 72.1           a1 = 90.7238        b1 = -94.158
// L2 = 72.1           a2 = 90.7238        b2 = -87.79
// CIE ΔE2000 = ΔE00 = 1.88699254643

// L1 = 59.981         a1 = -70.0          b1 = -88.902
// L2 = 62.8           a2 = -70.0          b2 = -96.92
// CIE ΔE2000 = ΔE00 = 2.9102507501

// L1 = 89.0           a1 = -27.068        b1 = -122.0
// L2 = 94.39          a2 = -27.068        b2 = -122.0
// CIE ΔE2000 = ΔE00 = 3.3233485057

// L1 = 18.67          a1 = 4.8            b1 = -88.4
// L2 = 18.67          a2 = 12.48          b2 = -88.4
// CIE ΔE2000 = ΔE00 = 4.24856908034

// L1 = 83.2491        a1 = -23.4          b1 = 28.0
// L2 = 88.37          a2 = -23.4          b2 = 22.0
// CIE ΔE2000 = ΔE00 = 4.47984413885

// L1 = 53.4379        a1 = 124.735        b1 = -3.0
// L2 = 50.0           a2 = 61.0134        b2 = -4.0
// CIE ΔE2000 = ΔE00 = 12.80088557102

// L1 = 52.4679        a1 = 91.46          b1 = 116.402
// L2 = 49.1           a2 = 96.537         b2 = 75.95
// CIE ΔE2000 = ΔE00 = 14.34166735917

