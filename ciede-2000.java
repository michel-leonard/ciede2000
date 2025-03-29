// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
import static java.lang.Math.hypot;
import static java.lang.Math.atan2;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.exp;

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
static double ciede_2000(final double l_1, final double a_1, final double b_1, final double l_2, final double a_2, final double b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	final double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	final double c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	h_1 += 2.0 * PI * Boolean.compare(h_1 < 0.0, false);
	h_2 += 2.0 * PI * Boolean.compare(h_2 < 0.0, false);
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (PI - 1E-14 < n && n < PI + 1E-14)
		n = PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		if (0.0 < h_d)
			h_d -= PI;
		else
			h_d += PI;
		h_m += PI;
	}
	final double p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	final double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
			* sin(PI / 3.0 * exp(p * p / (-25.0 * PI * PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	final double t = 1.0	+ 0.24 * sin(2.0 * h_m + PI * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)
				- 0.17 * sin(h_m + PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
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

// L1 = 54.3           a1 = -111.0385      b1 = 39.0
// L2 = 54.3           a2 = -111.0385      b2 = 39.077
// CIE ΔE2000 = ΔE00 = 0.0229425953

// L1 = 2.8127         a1 = -78.5          b1 = 55.752
// L2 = 2.8127         a2 = -78.5          b2 = 55.91
// CIE ΔE2000 = ΔE00 = 0.04614586884

// L1 = 57.0           a1 = 54.529         b1 = -13.4
// L2 = 57.7809        a2 = 54.529         b2 = -13.9075
// CIE ΔE2000 = ΔE00 = 0.74775680236

// L1 = 76.7           a1 = 56.4519        b1 = -89.0
// L2 = 78.57          a2 = 59.0           b2 = -89.0
// CIE ΔE2000 = ΔE00 = 1.74342103515

// L1 = 80.81          a1 = 59.327         b1 = 46.0
// L2 = 80.81          a2 = 68.0           b2 = 46.0
// CIE ΔE2000 = ΔE00 = 3.12005997874

// L1 = 22.7           a1 = -58.3          b1 = 35.2
// L2 = 27.3           a2 = -60.9893       b2 = 39.9
// CIE ΔE2000 = ΔE00 = 3.69731651916

// L1 = 63.1           a1 = -78.0          b1 = 76.0
// L2 = 69.9           a2 = -103.434       b2 = 66.7889
// CIE ΔE2000 = ΔE00 = 8.99979779273

// L1 = 8.053          a1 = 103.32         b1 = -99.7031
// L2 = 23.5           a2 = 86.28          b2 = -89.66
// CIE ΔE2000 = ΔE00 = 10.71252998979

// L1 = 26.04          a1 = -35.4          b1 = -24.901
// L2 = 47.87          a2 = -53.0          b2 = -38.0483
// CIE ΔE2000 = ΔE00 = 19.49599891372

// L1 = 82.44          a1 = -47.99         b1 = 63.6104
// L2 = 26.47          a2 = 5.77           b2 = -7.795
// CIE ΔE2000 = ΔE00 = 65.19822844459
