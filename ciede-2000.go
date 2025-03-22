// This function written in Go is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

package main

import "math"

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
func ciede_2000(l_1 float64, a_1 float64, b_1 float64, l_2 float64, a_2 float64, b_2 float64) float64 {
	// Working with the CIEDE2000 color-difference formula.
	const (
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		k_l = 1.0
		k_c = 1.0
		k_h = 1.0
	)
	n := (math.Hypot(a_1, b_1) + math.Hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - math.Sqrt(n / (n + 6103515625.0)))
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 := math.Hypot(a_1 * n, b_1)
	c_2 := math.Hypot(a_2 * n, b_2)
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 := math.Atan2(b_1, a_1 * n)
	h_2 := math.Atan2(b_2, a_2 * n)
	if h_1 < 0.0 { h_1 += 2.0 * math.Pi }
	if h_2 < 0.0 { h_2 += 2.0 * math.Pi }
	n = math.Abs(h_2 - h_1)
	// Cross-implementation consistent rounding.
	if math.Pi - 1E-14 < n && n < math.Pi + 1E-14 { n = math.Pi }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	h_m := 0.5 * h_1 + 0.5 * h_2
	h_d := (h_2 - h_1) * 0.5
	if math.Pi < n {
		if 0.0 < h_d {
			h_d -= math.Pi
		} else {
			h_d += math.Pi
		}
		h_m += math.Pi
	}
	p := (36.0 * h_m - 55.0 * math.Pi)
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	r_t :=	-2.0 * math.Sqrt(n / (n + 6103515625.0)) *
			math.Sin(math.Pi / 3.0 * math.Exp(p * p / (-25.0 * math.Pi * math.Pi)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	// Lightness.
	l := (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / math.Sqrt(20.0 + n)))
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	t := 1.0 	+ 0.24 * math.Sin(2.0 * h_m + math.Pi / 2.0) +
				0.32 * math.Sin(3.0 * h_m + 8.0 * math.Pi / 15.0) -
				0.17 * math.Sin(h_m + math.Pi / 3.0) -
				0.20 * math.Sin(4.0 * h_m + 3.0 * math.Pi / 20.0)
	n = c_1 + c_2
	// Hue.
	h := 2.0 * math.Sqrt(c_1 * c_2) * math.Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	// Chroma.
	c := (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return math.Sqrt(l * l + h * h + c * c + c * h * r_t)
}

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(28.0, -35.0, 112.8023) vs lab(28.0, -35.0, 112.8023) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(6.6, 41.4, 28.0) vs lab(6.6, 41.4, 28.0022) expects ΔE2000 = ΔE00 = 0.00121971374
// Testing lab(123.082, 122.0, 117.476) vs lab(123.082, 122.109, 117.476) expects ΔE2000 = ΔE00 = 0.02906116806
// Testing lab(123.0, -20.0, -99.67) vs lab(123.116, -20.0, -100.0) expects ΔE2000 = ΔE00 = 0.07242247588
// Testing lab(51.121, -30.402, -22.197) vs lab(51.121, -30.35, -22.0) expects ΔE2000 = ΔE00 = 0.09364751666
// Testing lab(84.0, -88.3813, 26.82) vs lab(84.0, -88.3813, 27.4412) expects ΔE2000 = ΔE00 = 0.22332086247
// Testing lab(101.274, 93.18, -14.0) vs lab(102.2107, 94.5753, -14.0) expects ΔE2000 = ΔE00 = 0.59346825702
// Testing lab(100.2143, -97.98, 112.3232) vs lab(101.223, -99.29, 112.3232) expects ΔE2000 = ΔE00 = 0.63698183939
// Testing lab(1.861, 84.0505, -1.43) vs lab(1.861, 89.11, -1.43) expects ΔE2000 = ΔE00 = 1.03357868814
// Testing lab(48.057, 18.982, -62.8) vs lab(48.057, 21.0, -62.8) expects ΔE2000 = ΔE00 = 1.3028007085
// Testing lab(32.0, 116.1112, 54.2) vs lab(32.0, 116.1112, 58.26) expects ΔE2000 = ΔE00 = 1.39290680505
// Testing lab(126.0, 116.83, -10.0) vs lab(126.0, 116.83, -15.6) expects ΔE2000 = ΔE00 = 1.6058181335
// Testing lab(83.271, 20.6, 126.145) vs lab(83.271, 24.9, 126.145) expects ΔE2000 = ΔE00 = 2.0040676224
// Testing lab(34.6, -116.0, 88.3) vs lab(36.2, -116.0, 80.6) expects ΔE2000 = ΔE00 = 2.13456362856
// Testing lab(61.2, -103.4, -68.6761) vs lab(63.97, -103.4, -65.99) expects ΔE2000 = ΔE00 = 2.45481978525
// Testing lab(109.5, 9.9562, 89.0) vs lab(111.7375, 6.6183, 95.0) expects ΔE2000 = ΔE00 = 2.66476882207
// Testing lab(58.0, 71.62, -55.4) vs lab(58.0, 76.494, -49.4) expects ΔE2000 = ΔE00 = 3.02697999676
// Testing lab(56.45, 104.396, 109.085) vs lab(60.02, 104.2794, 109.085) expects ΔE2000 = ΔE00 = 3.2206106973
// Testing lab(94.521, 125.748, 96.7) vs lab(100.3, 128.804, 96.7) expects ΔE2000 = ΔE00 = 3.46204430031
// Testing lab(108.1, -110.8, -1.06) vs lab(108.1, -104.35, -10.0) expects ΔE2000 = ΔE00 = 3.78067563656
// Testing lab(78.958, -26.1, 17.0) vs lab(78.958, -26.1, 10.0) expects ΔE2000 = ΔE00 = 4.08986000709
// Testing lab(65.3, 10.621, 116.1863) vs lab(65.3, 2.0, 116.1863) expects ΔE2000 = ΔE00 = 4.20515051905
// Testing lab(52.7, 19.0, -36.44) vs lab(54.82, 10.47, -28.0) expects ΔE2000 = ΔE00 = 4.45553994257
// Testing lab(57.0, 32.864, -60.691) vs lab(61.8, 29.75, -60.691) expects ΔE2000 = ΔE00 = 4.62891657151
// Testing lab(123.0, 1.0, -24.79) vs lab(117.0, -1.6097, -29.69) expects ΔE2000 = ΔE00 = 4.96484845496
// Testing lab(117.19, 75.448, 2.3975) vs lab(115.7, 66.2, -9.0) expects ΔE2000 = ΔE00 = 5.29808184185
// Testing lab(41.15, -120.9, 77.79) vs lab(38.4, -89.2, 77.0) expects ΔE2000 = ΔE00 = 6.63736445301
// Testing lab(57.0, -62.5937, -44.0) vs lab(51.4587, -51.894, -29.0) expects ΔE2000 = ΔE00 = 7.42082702533
// Testing lab(37.7294, -78.11, -38.0) vs lab(41.0, -49.3, -24.218) expects ΔE2000 = ΔE00 = 8.13846254018
// Testing lab(86.0, 6.0, -98.507) vs lab(95.0, -9.0, -99.87) expects ΔE2000 = ΔE00 = 9.22750083686
// Testing lab(56.889, -65.8955, -44.496) vs lab(52.3, -97.53, -36.762) expects ΔE2000 = ΔE00 = 10.43933033327
// Testing lab(57.8, 61.0, 56.56) vs lab(66.1, 66.0212, 39.57) expects ΔE2000 = ΔE00 = 11.39725669819
// Testing lab(36.462, 35.2, 102.6916) vs lab(21.803, 39.34, 82.73) expects ΔE2000 = ΔE00 = 13.09391396458
// Testing lab(107.21, -88.0, 0.19) vs lab(122.02, -85.107, 27.0) expects ΔE2000 = ΔE00 = 13.32600509206
// Testing lab(127.2, 5.293, -35.33) vs lab(115.3413, 55.0, -125.1872) expects ΔE2000 = ΔE00 = 15.04161110366
// Testing lab(55.763, 34.0, 85.401) vs lab(40.7138, 40.62, 104.0) expects ΔE2000 = ΔE00 = 15.32245413793
// Testing lab(74.6, -75.972, -40.7) vs lab(69.737, -126.039, -15.0) expects ΔE2000 = ΔE00 = 16.94317701909
// Testing lab(70.0, -26.015, 90.19) vs lab(65.8674, 3.787, 54.4) expects ΔE2000 = ΔE00 = 17.22345924128
// Testing lab(106.27, 51.9491, -79.713) vs lab(102.5647, 66.7, -40.64) expects ΔE2000 = ΔE00 = 18.56464413972
// Testing lab(92.71, -31.988, -5.1) vs lab(117.0, -76.954, 1.02) expects ΔE2000 = ΔE00 = 19.16138724201
// Testing lab(18.4, -22.38, -39.2) vs lab(4.0, 26.1, -89.565) expects ΔE2000 = ΔE00 = 20.69596469086
// Testing lab(81.6, 51.0, 4.0) vs lab(89.0, 82.0, 55.77) expects ΔE2000 = ΔE00 = 21.20115369478
// Testing lab(65.4619, -19.2425, 71.9) vs lab(94.924, -10.0, 104.8) expects ΔE2000 = ΔE00 = 22.51389148499
// Testing lab(76.31, 9.4, -30.9) vs lab(86.49, 64.6827, -46.8) expects ΔE2000 = ΔE00 = 23.89926468712
// Testing lab(116.0, -26.29, -32.1574) vs lab(90.34, -48.0, -3.491) expects ΔE2000 = ΔE00 = 24.56358836573
// Testing lab(79.664, -113.0, -36.274) vs lab(119.9, -29.8235, -128.0) expects ΔE2000 = ΔE00 = 39.28066225894
// Testing lab(70.373, -31.4605, 63.4) vs lab(82.0, -44.64, -58.0956) expects ΔE2000 = ΔE00 = 58.06219728287
// Testing lab(128.0, 120.2, -88.0) vs lab(120.196, -41.276, 41.123) expects ΔE2000 = ΔE00 = 93.52111902422
// Testing lab(54.179, -52.0, 80.74) vs lab(124.49, 104.0, -70.867) expects ΔE2000 = ΔE00 = 110.33005315852
// Testing lab(118.6, -114.3481, 123.3) vs lab(15.01, 105.7, 50.0) expects ΔE2000 = ΔE00 = 131.1437610034

