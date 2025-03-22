// This function written in C99 is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

#include <math.h>

// Expressly defining constants ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

#ifndef M_PI_2
#define M_PI_2 1.57079632679489661923132169164
#endif

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
static double ciede_2000(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const double c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	h_1 += 2.0 * M_PI * (h_1 < 0.0);
	h_2 += 2.0 * M_PI * (h_2 < 0.0);
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
	const double p = (36.0 * h_m - 55.0 * M_PI);
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0 	+ 0.24 * sin(2.0 * h_m + M_PI_2)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI_2 / 10.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// Compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o ciede-2000-compiled ciede-2000.c -lm

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(37.64, 82.72, 47.0) vs lab(37.64, 82.72, 47.0) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(0.7, 85.5001, -51.69) vs lab(0.7, 85.43, -51.69) expects ΔE2000 = ΔE00 = 0.01665040319
// Testing lab(73.1, -104.0, -89.0) vs lab(73.1, -103.84, -89.0) expects ΔE2000 = ΔE00 = 0.0315361381
// Testing lab(55.93, 27.04, -121.41) vs lab(56.0, 27.04, -121.41) expects ΔE2000 = ΔE00 = 0.06532353411
// Testing lab(50.1585, -30.0, 24.2) vs lab(50.1585, -30.0, 24.4) expects ΔE2000 = ΔE00 = 0.09767143748
// Testing lab(125.918, -99.6748, -55.72) vs lab(125.918, -99.2368, -56.0) expects ΔE2000 = ΔE00 = 0.15543908578
// Testing lab(62.228, 11.6, 106.789) vs lab(62.228, 12.1, 109.0) expects ΔE2000 = ΔE00 = 0.40445310474
// Testing lab(98.2, 104.111, -96.1) vs lab(98.76, 106.43, -96.1) expects ΔE2000 = ΔE00 = 0.64820263832
// Testing lab(103.167, -29.8744, -72.25) vs lab(103.167, -29.8744, -68.23) expects ΔE2000 = ΔE00 = 0.87129092065
// Testing lab(11.0063, 117.6, 12.0) vs lab(11.0063, 125.65, 13.2) expects ΔE2000 = ΔE00 = 1.2554895042
// Testing lab(22.3628, -109.7, -2.2664) vs lab(24.3871, -109.7, -2.2664) expects ΔE2000 = ΔE00 = 1.45229956884
// Testing lab(104.711, -82.7266, -55.8439) vs lab(104.711, -88.0, -63.07) expects ΔE2000 = ΔE00 = 1.76573357956
// Testing lab(61.7, -50.69, 114.5) vs lab(61.7, -57.0, 114.5) expects ΔE2000 = ΔE00 = 2.02234327291
// Testing lab(59.645, -69.11, 64.2) vs lab(59.645, -78.141, 64.2) expects ΔE2000 = ΔE00 = 2.34264009009
// Testing lab(69.3974, 94.65, 92.95) vs lab(72.0, 91.6602, 95.442) expects ΔE2000 = ΔE00 = 2.59364485808
// Testing lab(5.0, -22.0, 19.829) vs lab(6.5739, -27.0, 19.829) expects ΔE2000 = ΔE00 = 2.7149181845
// Testing lab(53.899, 61.8911, 72.29) vs lab(53.899, 55.0, 72.29) expects ΔE2000 = ΔE00 = 2.93720132235
// Testing lab(117.93, 60.922, 43.85) vs lab(124.601, 60.922, 42.81) expects ΔE2000 = ΔE00 = 3.26318730477
// Testing lab(123.66, -44.919, -102.742) vs lab(130.96, -44.919, -102.742) expects ΔE2000 = ΔE00 = 3.38320922903
// Testing lab(3.25, -80.97, -4.0516) vs lab(3.25, -80.97, 4.0) expects ΔE2000 = ΔE00 = 3.67755363612
// Testing lab(54.2, -18.0822, 96.3454) vs lab(56.0, -24.3, 90.8) expects ΔE2000 = ΔE00 = 3.94498861823
// Testing lab(102.2079, -97.7152, 29.17) vs lab(110.0, -97.7152, 27.0) expects ΔE2000 = ΔE00 = 4.3019963528
// Testing lab(7.88, 75.7, -21.4) vs lab(12.48, 85.4535, -14.7) expects ΔE2000 = ΔE00 = 4.57225130183
// Testing lab(0.4, 120.39, -121.75) vs lab(7.547, 111.0464, -121.75) expects ΔE2000 = ΔE00 = 4.81939800997
// Testing lab(122.0, -51.46, -29.1) vs lab(122.31, -42.1, -17.8244) expects ΔE2000 = ΔE00 = 5.07219481694
// Testing lab(27.0, 113.0, 111.0) vs lab(29.62, 117.6, 95.52) expects ΔE2000 = ΔE00 = 5.97632162431
// Testing lab(82.8, -8.8525, -77.4) vs lab(73.6499, -12.251, -63.61) expects ΔE2000 = ΔE00 = 6.83878526677
// Testing lab(127.49, -79.1, -74.26) vs lab(115.0, -102.6519, -88.8) expects ΔE2000 = ΔE00 = 7.48675328978
// Testing lab(80.8983, -65.21, -90.44) vs lab(84.3, -93.275, -75.14) expects ΔE2000 = ΔE00 = 8.91221437038
// Testing lab(49.85, 106.09, 38.0) vs lab(42.9, 99.8, 53.688) expects ΔE2000 = ΔE00 = 9.5116272096
// Testing lab(125.42, -90.9, 93.1019) vs lab(121.4, -106.1, 56.0) expects ΔE2000 = ΔE00 = 11.04450584335
// Testing lab(91.0, -66.0, -64.47) vs lab(91.0, -76.398, -34.0) expects ΔE2000 = ΔE00 = 11.53312658648
// Testing lab(103.0, -88.0, 68.4) vs lab(98.16, -38.3872, 37.0) expects ΔE2000 = ΔE00 = 13.01484644661
// Testing lab(114.0, 121.782, 14.0) vs lab(90.5, 97.394, 16.5) expects ΔE2000 = ΔE00 = 13.92527374063
// Testing lab(72.4, -57.6, -1.3) vs lab(57.7632, -91.6, -6.6739) expects ΔE2000 = ΔE00 = 14.46814509617
// Testing lab(86.1936, -44.0, -63.0) vs lab(95.0, -112.92, -92.0) expects ΔE2000 = ΔE00 = 15.30330759451
// Testing lab(81.04, 125.61, 68.0) vs lab(103.8508, 79.26, 37.86) expects ΔE2000 = ΔE00 = 16.71209218256
// Testing lab(55.559, 59.2116, -100.829) vs lab(47.256, 27.309, -97.1) expects ΔE2000 = ΔE00 = 17.9145000998
// Testing lab(79.4, -116.508, -77.742) vs lab(95.8, -49.9, -83.52) expects ΔE2000 = ΔE00 = 18.77151360151
// Testing lab(127.1454, -45.68, -86.1882) vs lab(92.84, -43.27, -126.0) expects ΔE2000 = ΔE00 = 19.22017090664
// Testing lab(118.152, -67.0, 37.9617) vs lab(102.432, -100.0, -2.647) expects ΔE2000 = ΔE00 = 20.67353194958
// Testing lab(92.36, 93.297, -41.2334) vs lab(93.5, 124.0, 27.517) expects ΔE2000 = ΔE00 = 21.30170598504
// Testing lab(87.8, 8.1645, -74.45) vs lab(115.394, -19.178, -88.95) expects ΔE2000 = ΔE00 = 22.3255632532
// Testing lab(37.2269, 73.751, -119.1) vs lab(30.0, -19.3, -21.18) expects ΔE2000 = ΔE00 = 23.83473764388
// Testing lab(81.4, 42.07, 19.783) vs lab(51.35, 29.555, 10.5315) expects ΔE2000 = ΔE00 = 25.0250808199
// Testing lab(100.957, -117.59, -4.463) vs lab(63.3927, -14.2104, -117.2876) expects ΔE2000 = ΔE00 = 49.56459971951
// Testing lab(67.8261, 57.5569, 75.0) vs lab(25.167, -38.2, -43.2) expects ΔE2000 = ΔE00 = 71.16600443689
// Testing lab(22.1, -54.66, 20.0) vs lab(36.0, 64.2, -6.724) expects ΔE2000 = ΔE00 = 80.12742632801
// Testing lab(96.5611, -61.6251, -56.058) vs lab(76.8498, 121.7, -36.8162) expects ΔE2000 = ΔE00 = 102.82990335824
// Testing lab(2.1, 34.27, -34.9) vs lab(124.0, -100.0, 116.9615) expects ΔE2000 = ΔE00 = 134.39242059294
