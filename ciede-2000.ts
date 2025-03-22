// This function written in TypeScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
function ciede_2000(l_1: number, a_1: number, b_1: number, l_2: number, a_2: number, b_2: number): number {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const k_l = 1.0, k_c = 1.0, k_h = 1.0;
	let n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * Math.PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * Math.PI;
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	const p = (36.0 * h_m - 55.0 * Math.PI);
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
		* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math.PI / 2.0)
			+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
			- 0.17 * Math.sin(h_m + Math.PI / 3.0)
			- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(36.45, -16.422, 45.74) vs lab(36.45, -16.422, 45.74) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(112.05, -108.0, 96.8906) vs lab(112.094, -108.0, 96.8906) expects ΔE2000 = ΔE00 = 0.02281361544
// Testing lab(17.0, -11.19, -25.7977) vs lab(17.0, -11.19, -25.7) expects ΔE2000 = ΔE00 = 0.04185034758
// Testing lab(41.73, -48.643, -79.0) vs lab(41.73, -48.643, -78.7591) expects ΔE2000 = ΔE00 = 0.05274190107
// Testing lab(5.7142, -30.09, 90.0) vs lab(5.87, -30.09, 90.0) expects ΔE2000 = ΔE00 = 0.0938694872
// Testing lab(96.0, -14.0, -103.9) vs lab(96.0, -13.8, -105.6) expects ΔE2000 = ΔE00 = 0.2027749378
// Testing lab(126.3292, -33.461, -123.2) vs lab(126.3292, -31.697, -124.04) expects ΔE2000 = ΔE00 = 0.549746566
// Testing lab(1.83, -92.5678, -29.333) vs lab(3.0564, -92.5678, -28.5489) expects ΔE2000 = ΔE00 = 0.78077010402
// Testing lab(71.0, -112.94, -89.67) vs lab(71.5905, -107.192, -87.3728) expects ΔE2000 = ΔE00 = 1.03139146853
// Testing lab(101.592, -30.0, -123.0) vs lab(101.592, -34.2021, -124.0) expects ΔE2000 = ΔE00 = 1.33681498824
// Testing lab(123.8, -101.0, -123.8) vs lab(125.82, -109.0, -129.6) expects ΔE2000 = ΔE00 = 1.58476886968
// Testing lab(99.576, 32.949, -104.0) vs lab(99.576, 32.949, -109.753) expects ΔE2000 = ΔE00 = 1.82338136887
// Testing lab(121.0, 51.0, -90.356) vs lab(125.0, 51.0, -91.9571) expects ΔE2000 = ΔE00 = 2.00432472353
// Testing lab(15.6, 112.98, -59.8) vs lab(17.0, 104.0, -52.0) expects ΔE2000 = ΔE00 = 2.17522318652
// Testing lab(116.9999, -59.984, -27.0) vs lab(116.9999, -70.0, -30.2) expects ΔE2000 = ΔE00 = 2.54471873925
// Testing lab(8.61, 68.31, -24.5378) vs lab(12.8, 68.31, -27.3531) expects ΔE2000 = ΔE00 = 2.84628590349
// Testing lab(16.0, -57.0, -44.84) vs lab(19.7, -57.0, -40.101) expects ΔE2000 = ΔE00 = 3.02145036327
// Testing lab(8.65, 99.327, -118.0) vs lab(13.81, 99.327, -118.0) expects ΔE2000 = ΔE00 = 3.27054392768
// Testing lab(84.354, 38.0042, -66.5634) vs lab(86.926, 42.2198, -64.091) expects ΔE2000 = ΔE00 = 3.55753480451
// Testing lab(104.0, 96.05, 29.04) vs lab(109.6, 86.2387, 29.04) expects ΔE2000 = ΔE00 = 3.71231112253
// Testing lab(45.3525, 15.0, 116.9) vs lab(49.3, 14.1201, 112.738) expects ΔE2000 = ΔE00 = 3.93154314823
// Testing lab(22.0, 71.0, -78.1) vs lab(27.69, 71.0, -75.7515) expects ΔE2000 = ΔE00 = 4.22684889083
// Testing lab(98.239, -51.0769, 49.0) vs lab(105.6275, -51.0769, 43.9398) expects ΔE2000 = ΔE00 = 4.51696306189
// Testing lab(93.076, -23.265, 65.6) vs lab(101.2512, -23.265, 65.6) expects ΔE2000 = ΔE00 = 4.79682251645
// Testing lab(120.0, -25.574, -46.6127) vs lab(122.0522, -38.2, -55.0778) expects ΔE2000 = ΔE00 = 4.90523929125
// Testing lab(38.0, -52.1, -126.4452) vs lab(43.8, -55.607, -115.273) expects ΔE2000 = ΔE00 = 5.5597706856
// Testing lab(7.452, -41.554, -111.5173) vs lab(3.0598, -28.5711, -82.6) expects ΔE2000 = ΔE00 = 6.49853469315
// Testing lab(71.0, -106.3026, -6.1616) vs lab(81.1123, -112.0, 0.426) expects ΔE2000 = ΔE00 = 7.80861576953
// Testing lab(62.923, -83.4, 1.5) vs lab(71.0, -97.95, -11.0) expects ΔE2000 = ΔE00 = 8.76794092829
// Testing lab(117.5, -60.3, -67.5) vs lab(100.69, -57.268, -84.9) expects ΔE2000 = ΔE00 = 9.97732359547
// Testing lab(75.0, 66.0, 5.394) vs lab(84.0, 75.6, -14.0) expects ΔE2000 = ΔE00 = 10.2000125111
// Testing lab(50.4, -106.0, 46.1) vs lab(60.64, -73.9, 31.18) expects ΔE2000 = ΔE00 = 11.64217804464
// Testing lab(72.609, 88.316, -42.2652) vs lab(89.3, 104.0, -58.129) expects ΔE2000 = ΔE00 = 12.18974408412
// Testing lab(121.0975, 22.9142, -93.8) vs lab(126.45, 57.089, -112.9) expects ΔE2000 = ΔE00 = 13.21145777261
// Testing lab(74.0, -70.0, 32.33) vs lab(82.2772, -61.83, 72.0) expects ΔE2000 = ΔE00 = 14.75307097189
// Testing lab(126.0, -46.0, 104.938) vs lab(121.867, -76.7, 67.6) expects ΔE2000 = ΔE00 = 16.03333557424
// Testing lab(127.4, 63.5, -101.873) vs lab(116.74, 8.2, -32.0) expects ΔE2000 = ΔE00 = 16.8995224854
// Testing lab(80.9274, -59.0, 11.381) vs lab(107.2, -74.0, 32.2854) expects ΔE2000 = ΔE00 = 17.90506485394
// Testing lab(80.405, 104.13, -102.73) vs lab(87.5, 106.2, -33.645) expects ΔE2000 = ΔE00 = 18.91775721664
// Testing lab(69.7, -37.0, 39.15) vs lab(55.0, -12.0, 10.0) expects ΔE2000 = ΔE00 = 19.6137582789
// Testing lab(93.9, -45.39, -38.773) vs lab(65.8, -66.253, -58.227) expects ΔE2000 = ΔE00 = 20.56228749697
// Testing lab(26.6276, -6.0, 28.39) vs lab(18.3698, -55.8373, 84.9) expects ΔE2000 = ΔE00 = 22.00931515368
// Testing lab(75.0, 19.0, 49.328) vs lab(68.3, 73.8, 67.03) expects ΔE2000 = ΔE00 = 22.73458967714
// Testing lab(70.6364, 82.3, 99.2809) vs lab(66.0, 30.2703, 17.363) expects ΔE2000 = ΔE00 = 24.0588259302
// Testing lab(72.35, 124.67, -17.2) vs lab(58.95, 55.244, -52.421) expects ΔE2000 = ΔE00 = 24.18669273897
// Testing lab(43.0, -47.22, 35.0) vs lab(97.0, -106.0, -15.0) expects ΔE2000 = ΔE00 = 49.46083280001
// Testing lab(111.95, 98.733, 101.395) vs lab(50.5665, 49.204, 7.859) expects ΔE2000 = ΔE00 = 51.28395245501
// Testing lab(1.29, 111.0015, -92.0) vs lab(19.9744, -36.2, 35.9462) expects ΔE2000 = ΔE00 = 89.42773385256
// Testing lab(25.8534, 82.0, 66.0) vs lab(122.8177, -93.5, -23.08) expects ΔE2000 = ΔE00 = 105.41634935023
// Testing lab(109.4, 116.612, -30.078) vs lab(20.0, -111.2967, 49.6944) expects ΔE2000 = ΔE00 = 138.34706654947

