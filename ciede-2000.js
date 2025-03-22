// This function written in JavaScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
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
	var h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	var p = (36.0 * h_m - 55.0 * Math.PI);
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
	var t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math.PI / 2.0)
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

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(85.0, -0.084, -73.61) vs lab(85.0, -0.084, -73.61) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(45.4, -83.0, -76.0) vs lab(45.4, -83.0, -75.97) expects ΔE2000 = ΔE00 = 0.00715622217
// Testing lab(125.0, -117.0, -25.0) vs lab(125.0, -117.0, -25.1) expects ΔE2000 = ΔE00 = 0.03628815651
// Testing lab(38.3, -13.6942, -110.0) vs lab(38.3, -13.6942, -109.494) expects ΔE2000 = ΔE00 = 0.06819041045
// Testing lab(67.7, -14.0, -79.357) vs lab(67.7, -13.7881, -79.357) expects ΔE2000 = ΔE00 = 0.09714433405
// Testing lab(105.0, 124.5399, -124.4) vs lab(105.0, 124.5399, -124.8741) expects ΔE2000 = ΔE00 = 0.11308939012
// Testing lab(35.0, 110.56, -115.8741) vs lab(35.0, 108.0, -115.0878) expects ΔE2000 = ΔE00 = 0.5127844978
// Testing lab(30.67, -31.8107, 66.18) vs lab(31.52, -32.6, 65.96) expects ΔE2000 = ΔE00 = 0.76860883493
// Testing lab(38.0491, -127.16, -113.0) vs lab(38.0491, -127.16, -119.0) expects ΔE2000 = ΔE00 = 1.03135048105
// Testing lab(121.8777, -64.307, -91.452) vs lab(122.373, -69.3933, -91.452) expects ΔE2000 = ΔE00 = 1.27525173322
// Testing lab(56.05, 46.2666, -104.05) vs lab(56.05, 49.0, -104.05) expects ΔE2000 = ΔE00 = 1.41173029219
// Testing lab(31.0, -78.0, -106.7) vs lab(31.0, -78.0, -97.9063) expects ΔE2000 = ΔE00 = 1.62787731712
// Testing lab(102.2, -42.0, -57.53) vs lab(102.2, -37.24, -59.064) expects ΔE2000 = ΔE00 = 1.8639682681
// Testing lab(22.0, -44.7438, -114.0) vs lab(22.0, -53.0, -121.0) expects ΔE2000 = ΔE00 = 2.230179137
// Testing lab(42.2765, -77.4734, 94.64) vs lab(42.2765, -84.2, 89.936) expects ΔE2000 = ΔE00 = 2.42279770831
// Testing lab(110.307, 23.094, 91.85) vs lab(114.95, 20.33, 85.577) expects ΔE2000 = ΔE00 = 2.81674919963
// Testing lab(56.2, -24.51, -81.0) vs lab(59.5, -24.51, -81.0) expects ΔE2000 = ΔE00 = 2.99370837717
// Testing lab(118.783, 5.13, 59.8592) vs lab(119.94, 0.2303, 59.8592) expects ΔE2000 = ΔE00 = 3.22714692765
// Testing lab(11.2, 0.268, -15.189) vs lab(11.2, 1.53, -10.9174) expects ΔE2000 = ΔE00 = 3.41215159695
// Testing lab(25.9, 116.86, -93.0) vs lab(30.0, 116.86, -102.01) expects ΔE2000 = ΔE00 = 3.82877618349
// Testing lab(7.0, -21.0, -59.3) vs lab(13.49, -21.0, -59.3) expects ΔE2000 = ΔE00 = 4.07512975411
// Testing lab(45.1861, 75.92, -26.0) vs lab(48.4, 84.179, -21.3362) expects ΔE2000 = ΔE00 = 4.19397725842
// Testing lab(113.3541, -97.16, -91.0419) vs lab(121.8001, -102.55, -90.0) expects ΔE2000 = ΔE00 = 4.36983867282
// Testing lab(76.0, -106.954, -112.0) vs lab(82.6, -113.7, -110.0) expects ΔE2000 = ΔE00 = 4.81957679385
// Testing lab(64.56, 61.2881, -101.0) vs lab(59.0, 65.0, -101.2) expects ΔE2000 = ΔE00 = 5.01577625412
// Testing lab(81.2674, -69.0, -66.0) vs lab(83.1427, -95.824, -82.95) expects ΔE2000 = ΔE00 = 5.61048350458
// Testing lab(13.9678, 111.443, 19.0) vs lab(12.09, 78.35, 13.09) expects ΔE2000 = ΔE00 = 6.42200080139
// Testing lab(51.0, -94.6808, -33.3181) vs lab(43.9, -115.51, -34.0) expects ΔE2000 = ΔE00 = 8.0293094503
// Testing lab(19.0, -122.0, 16.0) vs lab(10.868, -104.9, 30.764) expects ΔE2000 = ΔE00 = 8.34044836792
// Testing lab(70.76, -91.0, -30.97) vs lab(61.9772, -62.2643, -27.091) expects ΔE2000 = ΔE00 = 9.75106839619
// Testing lab(20.3, -21.89, -4.588) vs lab(25.8, -37.0034, -20.6698) expects ΔE2000 = ΔE00 = 10.95649257523
// Testing lab(120.0, -61.7513, 20.702) vs lab(112.0, -31.8, 24.0) expects ΔE2000 = ΔE00 = 11.64950758013
// Testing lab(54.511, 58.0, -12.82) vs lab(45.5, 38.0, 2.231) expects ΔE2000 = ΔE00 = 12.96763039893
// Testing lab(106.3, -31.2, -78.4) vs lab(125.95, -52.3, -63.0) expects ΔE2000 = ΔE00 = 13.23085997256
// Testing lab(104.8979, 90.1, 52.4809) vs lab(105.0, 76.6047, 14.24) expects ΔE2000 = ΔE00 = 14.38118240345
// Testing lab(101.04, -97.44, -77.0) vs lab(117.0, -121.06, -39.95) expects ΔE2000 = ΔE00 = 16.02133600126
// Testing lab(79.6, -85.7, -100.789) vs lab(66.0, -34.96, -109.208) expects ΔE2000 = ΔE00 = 16.73156897548
// Testing lab(117.0, -30.288, 35.0) vs lab(104.525, -88.3, 93.9923) expects ΔE2000 = ΔE00 = 17.9948990103
// Testing lab(116.255, -83.6552, 61.304) vs lab(92.15, -73.0, 20.95) expects ΔE2000 = ΔE00 = 18.19290024399
// Testing lab(18.569, -31.0, 28.1) vs lab(19.0, -18.0, 76.6177) expects ΔE2000 = ΔE00 = 19.78561845023
// Testing lab(76.017, -58.4236, 21.0) vs lab(95.533, -107.345, -3.0) expects ΔE2000 = ΔE00 = 20.27762679462
// Testing lab(104.0, 78.3942, 4.0) vs lab(92.713, 60.0, 42.53) expects ΔE2000 = ΔE00 = 21.19923138163
// Testing lab(112.8329, -18.422, 24.2) vs lab(88.9, 2.895, 16.5436) expects ΔE2000 = ΔE00 = 22.51963716375
// Testing lab(99.8, 2.3924, -124.0) vs lab(109.69, -71.8, -127.084) expects ΔE2000 = ΔE00 = 23.21861819146
// Testing lab(119.6, -83.8, -18.9825) vs lab(111.2, -63.0, -91.0) expects ΔE2000 = ΔE00 = 25.02570063153
// Testing lab(53.8, 0.256, -126.57) vs lab(28.7394, 1.1618, -55.18) expects ΔE2000 = ΔE00 = 26.84219986203
// Testing lab(67.823, 51.13, -89.4) vs lab(81.3, -102.83, 80.807) expects ΔE2000 = ΔE00 = 65.69783129546
// Testing lab(106.56, 53.0, -66.9405) vs lab(31.0, -19.13, -95.0) expects ΔE2000 = ΔE00 = 78.283684895
// Testing lab(31.709, -77.1738, -42.0) vs lab(78.372, 57.242, 6.0643) expects ΔE2000 = ΔE00 = 113.64368261382
// Testing lab(3.5, -64.8427, -91.0) vs lab(120.2, 106.912, 105.648) expects ΔE2000 = ΔE00 = 133.09124571706
