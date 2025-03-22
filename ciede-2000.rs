// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use std::f64::consts::PI;

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
fn ciede_2000(l_1: f64, a_1: f64, b_1: f64, l_2: f64, a_2: f64, b_2: f64) -> f64 {
	// Working with the CIEDE2000 color-difference formula.
	// K_L, K_C, K_H are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const K_L: f64 = 1.0;
	const K_C: f64 = 1.0;
	const K_H: f64 = 1.0;
	let mut n = (a_1.hypot(b_1) + a_2.hypot(b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - (n / (n + 6103515625.0)).sqrt());
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	let c_1: f64 = (a_1 * n).hypot(b_1);
	let c_2: f64 = (a_2 * n).hypot(b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let mut h_1 = b_1.atan2(a_1 * n);
	let mut h_2 = b_2.atan2(a_2 * n);
	if h_1 < 0.0 { h_1 += 2.0 * PI; }
	if h_2 < 0.0 { h_2 += 2.0 * PI; }
	n = (h_2 - h_1).abs();
	// Cross-implementation consistent rounding.
	 if (PI - 1e-14..=PI + 1e-14).contains(&n) { n = PI; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let mut h_m = 0.5 * h_1 + 0.5 * h_2;
	let mut h_d = (h_2 - h_1) * 0.5;
	if PI < n {
		if 0.0 < h_d { h_d -= PI; }
		else { h_d += PI; }
		h_m += PI;
	}
	let p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -2.0 * (n / (n + 6103515625.0)).sqrt() * (PI / 3.0 * (p * p / (-25.0 * PI * PI)).exp()).sin();
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l_2 - l_1) / (K_L * (1.0 + 0.015 * n / (20.0 + n).sqrt()));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0 	+ 0.24 * (2.0 * h_m + PI * 0.5).sin()
			+ 0.32 * (3.0 * h_m + 8.0 * PI / 15.0).sin()
			- 0.17 * (h_m + PI / 3.0).sin()
			- 0.20 * (4.0 * h_m + 3.0 * PI / 20.0).sin();
	n = c_1 + c_2;
	// Hue.
	let h = 2.0 * (c_1 * c_2).sqrt() * (h_d).sin() / (K_H * (1.0 + 0.0075 * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (K_C * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	(l * l + h * h + c * c + c * h * r_t).sqrt()
}

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(128.0, -65.44, -8.3) vs lab(128.0, -65.44, -8.3) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(8.8936, -102.8, 86.8) vs lab(8.8936, -102.8, 86.849) expects ΔE2000 = ΔE00 = 0.01088010727
// Testing lab(42.9, 53.0, -50.9) vs lab(42.9, 53.0, -51.0) expects ΔE2000 = ΔE00 = 0.0409705579
// Testing lab(14.9798, -70.632, 82.2) vs lab(14.9798, -70.632, 82.4934) expects ΔE2000 = ΔE00 = 0.07260054571
// Testing lab(54.0, -100.45, 23.903) vs lab(54.0, -100.9037, 23.903) expects ΔE2000 = ΔE00 = 0.08653303132
// Testing lab(40.0, 80.647, -4.0) vs lab(40.0, 79.4, -4.0) expects ΔE2000 = ΔE00 = 0.27145472641
// Testing lab(36.2134, 108.0, 43.8) vs lab(36.2134, 108.0, 42.586) expects ΔE2000 = ΔE00 = 0.437185933
// Testing lab(46.281, 9.9409, 48.1) vs lab(46.281, 9.0, 48.1) expects ΔE2000 = ΔE00 = 0.65133785804
// Testing lab(40.484, 126.842, 104.339) vs lab(40.484, 122.74, 104.339) expects ΔE2000 = ΔE00 = 1.03360227874
// Testing lab(44.0, -123.9805, 114.45) vs lab(44.0, -130.94, 114.0) expects ΔE2000 = ΔE00 = 1.24008633516
// Testing lab(105.0, 92.0, 92.142) vs lab(105.0, 87.59, 92.142) expects ΔE2000 = ΔE00 = 1.44597440672
// Testing lab(17.8958, -60.74, -9.44) vs lab(17.8958, -60.74, -6.119) expects ΔE2000 = ΔE00 = 1.77058503931
// Testing lab(126.0, -54.91, -2.354) vs lab(126.0, -56.7, -5.9) expects ΔE2000 = ΔE00 = 1.98149019821
// Testing lab(80.99, -2.2, 78.0) vs lab(80.99, -2.2, 68.455) expects ΔE2000 = ΔE00 = 2.22692613885
// Testing lab(105.9, 17.534, -93.3) vs lab(108.86, 21.0, -94.0) expects ΔE2000 = ΔE00 = 2.40280987434
// Testing lab(84.3, -84.61, 69.1) vs lab(88.083, -84.61, 65.4484) expects ΔE2000 = ΔE00 = 2.64030590341
// Testing lab(93.8774, 26.93, 36.21) vs lab(93.8774, 22.0, 36.21) expects ΔE2000 = ΔE00 = 3.04909996041
// Testing lab(108.51, 123.37, 80.5698) vs lab(108.51, 123.37, 70.6) expects ΔE2000 = ΔE00 = 3.20639516185
// Testing lab(104.649, 9.759, -33.0) vs lab(111.192, 9.759, -33.0) expects ΔE2000 = ΔE00 = 3.50600010455
// Testing lab(111.46, 49.901, 38.0) vs lab(111.46, 55.1911, 48.0) expects ΔE2000 = ΔE00 = 3.61485062757
// Testing lab(70.414, -83.48, 4.1603) vs lab(70.414, -83.48, 13.29) expects ΔE2000 = ΔE00 = 3.91631093378
// Testing lab(120.8, -57.333, -88.89) vs lab(129.32, -51.991, -88.89) expects ΔE2000 = ΔE00 = 4.27118639761
// Testing lab(123.31, 124.8963, 66.396) vs lab(132.76, 124.8963, 66.396) expects ΔE2000 = ΔE00 = 4.35763501084
// Testing lab(121.8, -7.91, 44.76) vs lab(123.0, -15.9, 46.9) expects ΔE2000 = ΔE00 = 4.83954494008
// Testing lab(120.8, -84.1097, -98.602) vs lab(114.2217, -76.0, -113.6) expects ΔE2000 = ΔE00 = 5.03282590435
// Testing lab(4.9657, 95.0, -84.772) vs lab(11.0, 120.3723, -98.15) expects ΔE2000 = ΔE00 = 5.62650839731
// Testing lab(35.5064, 99.0, 63.0) vs lab(36.049, 110.0, 86.8606) expects ΔE2000 = ΔE00 = 6.31169733828
// Testing lab(53.08, -79.0, -126.4543) vs lab(58.3689, -82.06, -96.0) expects ΔE2000 = ΔE00 = 7.45551466404
// Testing lab(124.91, -74.49, -99.5) vs lab(114.041, -97.816, -86.839) expects ΔE2000 = ΔE00 = 8.51254802065
// Testing lab(78.2445, 51.773, 73.7) vs lab(86.5, 82.0, 101.3076) expects ΔE2000 = ΔE00 = 9.46437310384
// Testing lab(39.0, -55.043, -81.443) vs lab(44.9647, -35.0, -109.73) expects ΔE2000 = ΔE00 = 10.28718759581
// Testing lab(14.8, 54.73, -112.37) vs lab(25.67, 18.075, -63.8992) expects ΔE2000 = ΔE00 = 11.85797599414
// Testing lab(114.726, -121.77, 85.5) vs lab(114.0, -73.856, 102.162) expects ΔE2000 = ΔE00 = 12.46634471848
// Testing lab(95.9508, 81.5, 96.0) vs lab(94.861, 45.0969, 89.163) expects ΔE2000 = ΔE00 = 13.50389100707
// Testing lab(53.9, -5.9, 73.0) vs lab(42.904, 8.8451, 88.51) expects ΔE2000 = ΔE00 = 14.1273649909
// Testing lab(37.4, -44.732, 85.444) vs lab(52.8, -48.0, 66.6) expects ΔE2000 = ΔE00 = 15.71728968186
// Testing lab(40.9, -27.743, -122.0544) vs lab(27.4, -7.035, -83.0) expects ΔE2000 = ΔE00 = 16.14982484415
// Testing lab(79.28, 88.0, -72.521) vs lab(104.0, 99.8, -50.52) expects ΔE2000 = ΔE00 = 17.33682468253
// Testing lab(46.0, -122.0, -115.9) vs lab(32.48, -93.0, -44.5) expects ΔE2000 = ΔE00 = 18.64194324706
// Testing lab(89.3484, 113.917, 21.77) vs lab(84.78, 44.7578, -11.7881) expects ΔE2000 = ΔE00 = 19.59176199882
// Testing lab(77.5, -108.58, 126.0) vs lab(105.05, -72.175, 60.436) expects ΔE2000 = ΔE00 = 20.80923048858
// Testing lab(70.9, -116.0, -72.253) vs lab(54.6383, -51.879, -89.0) expects ΔE2000 = ΔE00 = 21.35609387699
// Testing lab(10.33, -9.009, -93.0) vs lab(4.67, 32.7, -93.5) expects ΔE2000 = ΔE00 = 22.82541279255
// Testing lab(99.715, -98.892, 123.37) vs lab(88.05, -120.184, 31.07) expects ΔE2000 = ΔE00 = 24.02279121533
// Testing lab(95.2, 49.8454, 76.5) vs lab(84.9099, 12.074, 100.702) expects ΔE2000 = ΔE00 = 24.58449512986
// Testing lab(35.0346, -80.438, 8.255) vs lab(61.6, -20.0, -86.15) expects ΔE2000 = ΔE00 = 49.20890735575
// Testing lab(80.0, -88.78, -77.5569) vs lab(79.479, 66.3, -104.19) expects ΔE2000 = ΔE00 = 55.4456271891
// Testing lab(59.0, 93.545, -8.0) vs lab(114.863, -26.1738, -43.0) expects ΔE2000 = ΔE00 = 85.01403243966
// Testing lab(45.8, -51.79, -117.35) vs lab(115.842, 111.1864, -36.4) expects ΔE2000 = ΔE00 = 118.44269488166
// Testing lab(101.4, 119.5, 13.24) vs lab(5.76, -37.965, -110.1606) expects ΔE2000 = ΔE00 = 130.70704766893
