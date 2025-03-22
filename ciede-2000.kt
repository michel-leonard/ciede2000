// This function written in Kotlin is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import kotlin.math.*

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
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
	var h_m = 0.5 * h_1 + 0.5 * h_2;
	var h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		if (0.0 < h_d)
			h_d -= PI;
		else
			h_d += PI;
		h_m += PI;
	}
	val p = (36.0 * h_m - 55.0 * PI);
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
	val t = 1.0 + 0.24 * sin(2.0 * h_m + PI / 2.0) + 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)  
        	- 0.17 * sin(h_m + PI / 3.0) - 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0)
	n = c_1 + c_2;
	// Hue.
	val h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	val c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}
