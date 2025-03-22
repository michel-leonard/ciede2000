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
	val t = 1.0 + 0.24 * sin(2.0 * h_m + PI / 2.0)
		+ 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)  
        	- 0.17 * sin(h_m + PI / 3.0)
		- 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0)
	n = c_1 + c_2;
	// Hue.
	val h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	val c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(9.13, 10.0, -118.4) vs lab(9.13, 10.0, -118.4) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(7.5, -65.0, 111.0962) vs lab(7.5, -65.0, 111.0) expects ΔE2000 = ΔE00 = 0.01981803162
// Testing lab(89.4, -61.9, -81.3) vs lab(89.45, -61.9, -81.3) expects ΔE2000 = ΔE00 = 0.03149394749
// Testing lab(10.0, -71.384, 96.4) vs lab(10.0, -71.1205, 96.4) expects ΔE2000 = ΔE00 = 0.07097314617
// Testing lab(43.1566, -100.0106, -2.32) vs lab(43.1566, -100.49, -2.32) expects ΔE2000 = ΔE00 = 0.08706076815
// Testing lab(107.9536, -44.52, -90.246) vs lab(107.9536, -43.797, -89.0) expects ΔE2000 = ΔE00 = 0.26970439615
// Testing lab(44.0939, -64.2, 115.84) vs lab(44.0939, -64.2, 118.0) expects ΔE2000 = ΔE00 = 0.42831813557
// Testing lab(52.0, 0.24, 118.9358) vs lab(52.101, -1.4163, 118.9358) expects ΔE2000 = ΔE00 = 0.79296914178
// Testing lab(33.27, -68.0, -124.0249) vs lab(33.27, -64.0, -120.6312) expects ΔE2000 = ΔE00 = 0.87749511645
// Testing lab(126.209, -111.595, -100.7964) vs lab(128.6, -111.595, -100.7964) expects ΔE2000 = ΔE00 = 1.10738818601
// Testing lab(5.0, -3.39, -95.0) vs lab(5.05, -3.39, -103.8) expects ΔE2000 = ΔE00 = 1.49447431398
// Testing lab(29.0, -85.27, 50.0) vs lab(29.0, -93.4386, 50.0) expects ΔE2000 = ΔE00 = 1.80924313389
// Testing lab(49.0, -93.6054, -112.609) vs lab(49.0, -84.0106, -112.609) expects ΔE2000 = ΔE00 = 1.93657709322
// Testing lab(84.62, 127.922, 76.4) vs lab(84.62, 118.0, 76.4) expects ΔE2000 = ΔE00 = 2.23713386688
// Testing lab(127.8899, -15.5711, -81.515) vs lab(133.4802, -15.5711, -81.515) expects ΔE2000 = ΔE00 = 2.53135618003
// Testing lab(126.788, 124.6, 106.52) vs lab(128.0611, 123.3226, 115.0) expects ΔE2000 = ΔE00 = 2.73989980096
// Testing lab(4.52, 63.0, 38.8) vs lab(5.02, 63.0, 45.0) expects ΔE2000 = ΔE00 = 2.88272207896
// Testing lab(61.449, 17.5, -100.4) vs lab(61.449, 11.556, -100.4) expects ΔE2000 = ΔE00 = 3.22021345413
// Testing lab(37.391, -42.7437, 66.491) vs lab(39.0187, -51.38, 66.491) expects ΔE2000 = ΔE00 = 3.36701930389
// Testing lab(121.7, 96.0, -45.0) vs lab(129.77, 98.228, -45.0) expects ΔE2000 = ΔE00 = 3.808722275
// Testing lab(2.084, 95.92, 61.0933) vs lab(2.084, 87.801, 66.251) expects ΔE2000 = ΔE00 = 3.95860014838
// Testing lab(127.11, 87.32, 50.29) vs lab(127.11, 83.2, 58.68) expects ΔE2000 = ΔE00 = 4.26083582406
// Testing lab(91.9, -61.7, -13.0) vs lab(91.9, -61.7, -22.0) expects ΔE2000 = ΔE00 = 4.50068389246
// Testing lab(31.5521, -86.88, -24.7951) vs lab(34.4, -94.2591, -17.0) expects ΔE2000 = ΔE00 = 4.69431981924
// Testing lab(118.0157, -83.0, -70.0355) vs lab(118.8, -63.0, -69.6336) expects ΔE2000 = ΔE00 = 4.98128504795
// Testing lab(103.46, 103.85, 79.875) vs lab(96.108, 89.3697, 80.0) expects ΔE2000 = ΔE00 = 6.03716038029
// Testing lab(107.88, -99.279, -80.5) vs lab(100.865, -79.4467, -60.0) expects ΔE2000 = ΔE00 = 6.13172663628
// Testing lab(34.0, 61.4002, -106.478) vs lab(28.9499, 35.2, -73.68) expects ΔE2000 = ΔE00 = 7.85068065037
// Testing lab(11.8223, -54.0, -56.596) vs lab(4.5, -87.0, -80.6) expects ΔE2000 = ΔE00 = 8.91913443578
// Testing lab(117.0, -109.935, -49.0) vs lab(110.0, -72.0, -52.834) expects ΔE2000 = ΔE00 = 10.00439473589
// Testing lab(44.4267, -46.221, -122.605) vs lab(36.0, -51.0, -82.95) expects ΔE2000 = ΔE00 = 10.3548539358
// Testing lab(100.059, -111.0, -2.787) vs lab(109.6, -89.0, -23.9) expects ΔE2000 = ΔE00 = 11.65672152204
// Testing lab(32.172, -87.2, 14.28) vs lab(20.71, -93.12, -7.665) expects ΔE2000 = ΔE00 = 12.69155335625
// Testing lab(103.0, -96.713, -116.0) vs lab(88.4, -48.2066, -117.487) expects ΔE2000 = ΔE00 = 13.916671972
// Testing lab(88.39, 41.9129, 29.0) vs lab(78.2513, 55.4331, 65.7) expects ΔE2000 = ΔE00 = 14.94749219358
// Testing lab(38.132, 97.93, -16.525) vs lab(50.78, 92.343, 13.7) expects ΔE2000 = ΔE00 = 15.77852121446
// Testing lab(56.8, 58.4, -4.2) vs lab(77.9, 57.9, 1.794) expects ΔE2000 = ΔE00 = 17.07779894191
// Testing lab(12.063, 43.564, -16.6) vs lab(31.93, 77.481, -38.6) expects ΔE2000 = ΔE00 = 17.43744496941
// Testing lab(46.0, -95.7, -46.2) vs lab(35.32, -45.0, -61.5) expects ΔE2000 = ΔE00 = 18.59775993323
// Testing lab(19.9693, -22.42, -72.2) vs lab(27.12, -100.084, -102.9) expects ΔE2000 = ΔE00 = 19.67535953828
// Testing lab(50.6683, -21.0, -41.2) vs lab(44.4, -36.557, -7.499) expects ΔE2000 = ΔE00 = 20.58722519069
// Testing lab(33.483, 77.5494, 99.7483) vs lab(30.9, 28.0, 94.7345) expects ΔE2000 = ΔE00 = 21.11148956756
// Testing lab(93.0, -115.33, 125.044) vs lab(120.0, -86.4948, 39.0) expects ΔE2000 = ΔE00 = 22.65496711512
// Testing lab(26.45, -44.0, -6.005) vs lab(32.4888, -46.2757, 42.46) expects ΔE2000 = ΔE00 = 23.69638895124
// Testing lab(94.0, -92.1648, -37.712) vs lab(89.0, -73.9, 17.98) expects ΔE2000 = ΔE00 = 24.52955397749
// Testing lab(111.85, -8.0, 118.2376) vs lab(56.0, -48.0, 30.39) expects ΔE2000 = ΔE00 = 49.49615067826
// Testing lab(23.0, 27.0, 106.15) vs lab(27.0, -102.6, -37.0) expects ΔE2000 = ΔE00 = 59.80586504565
// Testing lab(104.6, -104.0, 63.0976) vs lab(123.2684, 91.9435, 83.0) expects ΔE2000 = ΔE00 = 89.0813591015
// Testing lab(1.714, -124.55, -123.45) vs lab(67.0, 31.332, -17.0) expects ΔE2000 = ΔE00 = 106.86149041649
// Testing lab(104.0, 108.91, -39.8993) vs lab(6.7842, -81.0874, -34.6982) expects ΔE2000 = ΔE00 = 127.20336052093
