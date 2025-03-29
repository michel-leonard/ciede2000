// This function written in JavaScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) {
	"use strict"
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	var c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	h_1 += 2.0 * Math.PI * (h_1 < 0.0);
	h_2 += 2.0 * Math.PI * (h_2 < 0.0);
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	var p = 36.0 * h_m - 55.0 * Math.PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
		* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	var l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	var t = 1.0	+ 0.24 * Math.sin(2.0 * h_m + Math.PI * 0.5)
			+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
			- 0.17 * Math.sin(h_m + Math.PI / 3.0)
			- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	var h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	var c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 73.6           a1 = -112.6         b1 = -27.899
// L2 = 73.6           a2 = -112.73        b2 = -27.899
// CIE ΔE2000 = ΔE00 = 0.02340226431

// L1 = 52.74          a1 = -53.7          b1 = -15.43
// L2 = 52.74          a2 = -53.4          b2 = -15.43
// CIE ΔE2000 = ΔE00 = 0.09402439218

// L1 = 98.6           a1 = 2.0            b1 = 96.0
// L2 = 98.9829        a2 = 4.9            b2 = 88.291
// CIE ΔE2000 = ΔE00 = 2.28917820032

// L1 = 0.8308         a1 = -40.8          b1 = 37.7537
// L2 = 0.8308         a2 = -40.8          b2 = 44.5
// CIE ΔE2000 = ΔE00 = 2.56898038789

// L1 = 71.5           a1 = 127.0          b1 = -100.1825
// L2 = 76.2           a2 = 118.722        b2 = -100.1825
// CIE ΔE2000 = ΔE00 = 3.86619913624

// L1 = 72.411         a1 = -7.61          b1 = -53.073
// L2 = 62.1484        a2 = 0.67           b2 = -114.0
// CIE ΔE2000 = ΔE00 = 12.07784104956

// L1 = 78.0           a1 = 51.1           b1 = -8.0
// L2 = 56.1           a2 = 18.8165        b2 = -9.0
// CIE ΔE2000 = ΔE00 = 21.82054366876

// L1 = 90.1           a1 = 69.2526        b1 = 40.6
// L2 = 56.82          a2 = 80.638         b2 = 52.8527
// CIE ΔE2000 = ΔE00 = 25.0354396219

// L1 = 1.6            a1 = -99.5          b1 = -60.8
// L2 = 54.601         a2 = -50.65         b2 = -51.0
// CIE ΔE2000 = ΔE00 = 41.6672431528

// L1 = 66.6           a1 = -55.92         b1 = 16.02
// L2 = 71.527         a2 = 109.0          b2 = -117.203
// CIE ΔE2000 = ΔE00 = 53.21434616075

