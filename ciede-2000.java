// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
import static java.lang.Math.hypot;
import static java.lang.Math.atan2;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.exp;

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
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
	double h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
	if (PI < n) {
		if (0.0 < h_d)
			h_d -= PI;
		else
			h_d += PI;
		h_m += PI;
	}
	final double p = (36.0 * h_m - 55.0 * PI);
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
	final double t = 1.0 + 0.24 * sin(2.0 * h_m + PI / 2.0)
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

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(75.0, -20.412, 102.5) vs lab(75.0, -20.412, 102.5) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(31.0, 38.1, -100.689) vs lab(31.0, 38.1, -100.6308) expects ΔE2000 = ΔE00 = 0.02031251581
// Testing lab(46.6, -9.344, -127.6) vs lab(46.6, -9.44, -127.6) expects ΔE2000 = ΔE00 = 0.03695828417
// Testing lab(19.07, -53.27, 96.3601) vs lab(19.07, -53.27, 96.58) expects ΔE2000 = ΔE00 = 0.05022495224
// Testing lab(109.0, -66.396, 3.999) vs lab(109.0, -66.0, 3.999) expects ΔE2000 = ΔE00 = 0.09992357217
// Testing lab(64.43, -9.9189, -34.5588) vs lab(64.43, -9.9189, -35.6443) expects ΔE2000 = ΔE00 = 0.34706237046
// Testing lab(107.0, -64.71, 31.667) vs lab(107.0, -64.18, 30.148) expects ΔE2000 = ΔE00 = 0.54078593682
// Testing lab(106.4, 38.4, 105.0) vs lab(107.03, 37.2122, 105.0) expects ΔE2000 = ΔE00 = 0.66238097294
// Testing lab(116.354, -14.978, 41.0) vs lab(118.224, -14.978, 42.0) expects ΔE2000 = ΔE00 = 1.0066144544
// Testing lab(73.521, -126.964, -66.0) vs lab(73.521, -119.0, -62.8) expects ΔE2000 = ΔE00 = 1.20496210828
// Testing lab(66.5618, 68.95, 116.22) vs lab(66.5618, 67.0, 119.8) expects ΔE2000 = ΔE00 = 1.57072834076
// Testing lab(18.47, -73.6, -34.0) vs lab(18.47, -67.0, -30.84) expects ΔE2000 = ΔE00 = 1.63251306013
// Testing lab(41.0974, 45.0189, 38.9559) vs lab(41.0974, 45.0189, 34.9997) expects ΔE2000 = ΔE00 = 2.00482633966
// Testing lab(118.293, -71.943, 59.0) vs lab(118.293, -81.287, 59.0) expects ΔE2000 = ΔE00 = 2.34576773635
// Testing lab(96.825, -91.5, 61.765) vs lab(96.825, -91.5, 52.711) expects ΔE2000 = ΔE00 = 2.50884933834
// Testing lab(77.41, 106.68, -48.7512) vs lab(80.8596, 106.68, -52.9) expects ΔE2000 = ΔE00 = 2.66402420474
// Testing lab(17.63, -104.0, 9.699) vs lab(17.63, -104.0, 2.0) expects ΔE2000 = ΔE00 = 2.97680502232
// Testing lab(44.79, -44.2, 32.0) vs lab(44.79, -54.03, 32.0) expects ΔE2000 = ΔE00 = 3.31451046141
// Testing lab(123.711, 104.932, -55.837) vs lab(131.0, 107.803, -55.837) expects ΔE2000 = ΔE00 = 3.42299175927
// Testing lab(85.318, 43.1, 28.514) vs lab(91.0, 43.1, 28.514) expects ΔE2000 = ΔE00 = 3.62258292458
// Testing lab(27.3, 65.0, -106.0) vs lab(32.384, 62.311, -106.0) expects ΔE2000 = ΔE00 = 4.09702259211
// Testing lab(91.0, 103.4326, 66.961) vs lab(97.4, 98.0, 66.961) expects ΔE2000 = ΔE00 = 4.11663709168
// Testing lab(89.0, -85.2987, -127.64) vs lab(95.7, -93.832, -127.64) expects ΔE2000 = ΔE00 = 4.42832253016
// Testing lab(67.22, 52.0, -65.0797) vs lab(70.0, 43.0, -65.0797) expects ΔE2000 = ΔE00 = 4.69619794025
// Testing lab(38.93, 115.8, 50.852) vs lab(34.75, 99.176, 49.639) expects ΔE2000 = ΔE00 = 4.88505549589
// Testing lab(29.0, -121.272, 49.0) vs lab(20.9542, -114.0, 42.9) expects ΔE2000 = ΔE00 = 6.09183503939
// Testing lab(23.643, -102.0, 112.0) vs lab(32.609, -102.622, 106.993) expects ΔE2000 = ΔE00 = 6.86799296296
// Testing lab(109.5925, 104.136, -100.0) vs lab(114.85, 112.2, -76.709) expects ΔE2000 = ΔE00 = 7.94282053945
// Testing lab(72.65, -84.7, 76.0) vs lab(68.63, -88.0, 112.0) expects ΔE2000 = ΔE00 = 8.16047745493
// Testing lab(115.6, -0.956, -108.0) vs lab(123.3, 16.83, -108.0) expects ΔE2000 = ΔE00 = 9.57777113091
// Testing lab(108.5, -58.3, -48.0) vs lab(114.225, -102.9, -53.26) expects ΔE2000 = ΔE00 = 10.72030420834
// Testing lab(97.57, 64.2, 98.95) vs lab(88.8148, 44.54, 53.49) expects ΔE2000 = ΔE00 = 12.0960306266
// Testing lab(11.29, 71.32, 34.69) vs lab(2.4, 33.68, 23.24) expects ΔE2000 = ΔE00 = 12.7100040414
// Testing lab(4.5205, -68.09, -76.7812) vs lab(7.5, -31.11, -111.0) expects ΔE2000 = ΔE00 = 13.84667341401
// Testing lab(28.81, 49.9645, -33.7658) vs lab(7.3, 49.584, -28.2) expects ΔE2000 = ΔE00 = 14.77769920391
// Testing lab(108.7, -72.5, -100.85) vs lab(109.418, -118.71, -62.781) expects ΔE2000 = ΔE00 = 15.64405350305
// Testing lab(112.3773, 49.69, 82.0) vs lab(97.093, 66.0, 60.44) expects ΔE2000 = ΔE00 = 16.20749037089
// Testing lab(67.594, -16.133, 31.646) vs lab(64.0, -67.23, 50.5988) expects ΔE2000 = ΔE00 = 17.72798792897
// Testing lab(33.46, -72.5265, -76.2) vs lab(8.1679, -74.5005, -53.64) expects ΔE2000 = ΔE00 = 18.74729268343
// Testing lab(110.2291, 69.868, 58.295) vs lab(106.7, 73.7, 120.99) expects ΔE2000 = ΔE00 = 19.21052467857
// Testing lab(113.0, 82.4, 39.635) vs lab(81.97, 97.2872, 18.99) expects ΔE2000 = ΔE00 = 20.81894715526
// Testing lab(21.8, -43.0, -44.0) vs lab(40.96, -50.0, -114.9769) expects ΔE2000 = ΔE00 = 21.29517598643
// Testing lab(83.8564, -51.69, 105.0) vs lab(94.4, -95.9, 52.2321) expects ΔE2000 = ΔE00 = 22.14349215617
// Testing lab(59.605, -23.0, -22.1) vs lab(52.563, -115.8, -79.4186) expects ΔE2000 = ΔE00 = 23.54984189092
// Testing lab(94.0296, -126.0, -46.912) vs lab(118.0, -59.162, 3.7969) expects ΔE2000 = ΔE00 = 24.80040427464
// Testing lab(94.907, -81.339, 35.0) vs lab(71.37, -112.586, -11.7) expects ΔE2000 = ΔE00 = 25.1522042667
// Testing lab(99.3, 53.4701, -107.48) vs lab(93.9, -66.8, -126.0) expects ΔE2000 = ΔE00 = 51.34769516073
// Testing lab(66.284, 121.0, 56.763) vs lab(82.0, -29.527, -41.0) expects ΔE2000 = ΔE00 = 81.68730470134
// Testing lab(126.49, -46.4, 18.7) vs lab(10.6, 90.53, 61.79) expects ΔE2000 = ΔE00 = 117.14241683064
// Testing lab(2.0, 109.6, 51.9861) vs lab(118.2, -54.71, 51.8) expects ΔE2000 = ΔE00 = 133.04909930124

