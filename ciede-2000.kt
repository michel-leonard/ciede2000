// This function written in Kotlin is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import kotlin.math.*

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
fun ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double): Double {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	val k_l = 1.0;
	val k_c = 1.0;
	val k_h = 1.0;
	var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	val c_1 = hypot(a_1 * n, b_1);
	val c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n);
	var h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * PI;
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (PI - 1E-14 < n && n < PI + 1E-14)
		n = PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5;
	var h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		if (0.0 < h_d)
			h_d -= PI;
		else
			h_d += PI;
		h_m += PI;
	}
	val p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	val r_t = -2.0 * sqrt(n / (n + 6103515625.0)) * sin(PI / 3.0 * exp((p * p) / (-25.0 * PI * PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	val l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	val t = 1.0 +	0.24 * sin(2.0 * h_m + PI * 0.5) +
			0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0) -
			0.17 * sin(h_m + PI / 3.0) -
			0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	val h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	val c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 22.8806        a1 = 19.411         b1 = 117.5
// L2 = 22.8806        a2 = 19.411         b2 = 117.4
// CIE ΔE2000 = ΔE00 = 0.0174628278

// L1 = 28.0           a1 = -61.29         b1 = 92.0
// L2 = 28.0           a2 = -61.29         b2 = 91.71
// CIE ΔE2000 = ΔE00 = 0.06826917587

// L1 = 24.51          a1 = 8.293          b1 = -89.956
// L2 = 24.51          a2 = 8.293          b2 = -89.061
// CIE ΔE2000 = ΔE00 = 0.21842512488

// L1 = 19.02          a1 = -73.0          b1 = 3.7
// L2 = 19.8           a2 = -73.0          b2 = 3.7
// CIE ΔE2000 = ΔE00 = 0.53644243768

// L1 = 27.3236        a1 = -92.5          b1 = 69.88
// L2 = 28.1215        a2 = -92.5          b2 = 69.88
// CIE ΔE2000 = ΔE00 = 0.60099784528

// L1 = 22.74          a1 = -31.72         b1 = -109.0
// L2 = 22.74          a2 = -21.86         b2 = -109.0
// CIE ΔE2000 = ΔE00 = 3.42924931333

// L1 = 40.0           a1 = -41.09         b1 = -27.46
// L2 = 43.0           a2 = -34.357        b2 = -27.46
// CIE ΔE2000 = ΔE00 = 3.81679463865

// L1 = 43.13          a1 = 15.0           b1 = 55.5905
// L2 = 47.5           a2 = 15.0           b2 = 51.71
// CIE ΔE2000 = ΔE00 = 4.35038741516

// L1 = 43.371         a1 = 26.4           b1 = 106.0
// L2 = 30.5908        a2 = 25.28          b2 = 48.0
// CIE ΔE2000 = ΔE00 = 19.22895169717

// L1 = 54.039         a1 = 123.5          b1 = -98.9878
// L2 = 89.4388        a2 = -1.7579        b2 = 37.766
// CIE ΔE2000 = ΔE00 = 71.81672313734
