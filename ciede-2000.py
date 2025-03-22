# This function written in Python is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2):
	from math import pi, sqrt, hypot, atan2, sin, exp
	# Working with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)))
	# hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = hypot(a_1 * n, b_1)
	c_2 = hypot(a_2 * n, b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = atan2(b_1, a_1 * n)
	h_2 = atan2(b_2, a_2 * n)
	h_1 += 2.0 * pi * (h_1 < 0.0)
	h_2 += 2.0 * pi * (h_2 < 0.0)
	n = abs(h_2 - h_1)
	# Cross-implementation consistent rounding.
	if pi - 1E-14 < n and n < pi + 1E-14:
		n = pi
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = 0.5 * h_1 + 0.5 * h_2
	h_d = (h_2 - h_1) * 0.5
	if pi < n :
		if (0.0 < h_d) :
			h_d -= pi
		else :
			h_d += pi
		h_m += pi
	p = (36.0 * h_m - 55.0 * pi)
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n / (n + 6103515625.0)) \
			* sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0 + 0.24 * sin(2.0 * h_m + pi / 2.0) \
			 + 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0) \
			 - 0.17 * sin(h_m + pi / 3.0) \
			 - 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returning the square root ensures that the result represents
	# the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t)

#
# More samples for the CIEDE2000 color difference formula implementation at https:#bit.ly/ciede2000-samples
#
# Testing lab(63.772, 124.0, -126.8218) vs lab(63.772, 124.0, -126.8218) expects ΔE2000 = ΔE00 = 0.0
# Testing lab(25.1, 76.9193, 125.25) vs lab(25.1, 76.96, 125.25) expects ΔE2000 = ΔE00 = 0.01492233121
# Testing lab(3.0, -65.0, -55.9) vs lab(3.0, -65.0, -56.0) expects ΔE2000 = ΔE00 = 0.02971171222
# Testing lab(101.1, 85.679, -67.9) vs lab(101.0, 85.679, -67.9) expects ΔE2000 = ΔE00 = 0.05672701542
# Testing lab(44.3, 56.1, 72.0) vs lab(44.3, 56.28, 72.0) expects ΔE2000 = ΔE00 = 0.07846027333
# Testing lab(56.14, -61.179, -114.447) vs lab(56.14, -61.179, -113.6) expects ΔE2000 = ΔE00 = 0.1350855852
# Testing lab(102.7, 49.6, -12.3302) vs lab(102.7, 48.0, -12.3302) expects ΔE2000 = ΔE00 = 0.51096224603
# Testing lab(93.138, -74.7474, 27.68) vs lab(93.138, -74.7474, 25.52) expects ΔE2000 = ΔE00 = 0.82983203145
# Testing lab(73.9, -25.6, -63.3) vs lab(73.9, -25.6, -59.54) expects ΔE2000 = ΔE00 = 0.89243963719
# Testing lab(74.8796, -5.04, -91.0) vs lab(74.8796, -2.632, -90.97) expects ΔE2000 = ΔE00 = 1.17070337526
# Testing lab(87.9419, -73.898, -36.054) vs lab(87.9419, -80.0, -36.054) expects ΔE2000 = ΔE00 = 1.56695747217
# Testing lab(5.0048, 19.5, 104.0) vs lab(7.9319, 19.5, 104.0) expects ΔE2000 = ΔE00 = 1.77447747566
# Testing lab(34.083, 13.0, -76.0) vs lab(34.083, 15.0, -73.475) expects ΔE2000 = ΔE00 = 2.02545595719
# Testing lab(94.201, -34.0861, -68.724) vs lab(97.78, -34.0861, -68.724) expects ΔE2000 = ΔE00 = 2.12199684635
# Testing lab(7.0, 14.0213, 17.5) vs lab(7.0, 14.0213, 13.876) expects ΔE2000 = ΔE00 = 2.46489777302
# Testing lab(113.7834, 31.5, -103.577) vs lab(119.0, 31.5, -103.577) expects ΔE2000 = ΔE00 = 2.61664206295
# Testing lab(95.0, -79.583, 12.0) vs lab(100.017, -79.583, 12.0) expects ΔE2000 = ΔE00 = 2.93479170192
# Testing lab(71.431, -24.044, 38.0) vs lab(75.4392, -21.2271, 38.0) expects ΔE2000 = ΔE00 = 3.32723371412
# Testing lab(111.157, 3.661, -72.665) vs lab(118.0, 3.661, -72.665) expects ΔE2000 = ΔE00 = 3.48002874736
# Testing lab(70.1671, -97.2671, 40.0) vs lab(75.0278, -97.2671, 40.0) expects ΔE2000 = ΔE00 = 3.64777020476
# Testing lab(100.0, -4.0, 122.48) vs lab(100.0, -12.911, 128.8231) expects ΔE2000 = ΔE00 = 3.94412390624
# Testing lab(48.08, 15.13, -85.78) vs lab(50.0, 5.334, -78.0) expects ΔE2000 = ΔE00 = 4.25610598016
# Testing lab(120.0, 66.7215, -122.543) vs lab(120.0, 56.813, -122.543) expects ΔE2000 = ΔE00 = 4.57327489805
# Testing lab(103.3, 56.8, -72.6596) vs lab(112.0, 56.8, -69.714) expects ΔE2000 = ΔE00 = 4.80862545345
# Testing lab(97.14, 128.0, 53.0) vs lab(91.5581, 114.3, 57.0) expects ΔE2000 = ΔE00 = 5.00375567624
# Testing lab(42.2138, -80.538, -42.0) vs lab(43.2347, -61.8, -29.3) expects ΔE2000 = ΔE00 = 5.14222881698
# Testing lab(7.4145, 28.67, -94.0) vs lab(13.0, 45.258, -107.0) expects ΔE2000 = ΔE00 = 6.4986912032
# Testing lab(16.3548, -62.0, -102.158) vs lab(18.93, -37.469, -119.3435) expects ΔE2000 = ΔE00 = 8.0006467023
# Testing lab(52.6483, 110.508, -99.1) vs lab(45.0772, 103.169, -77.6935) expects ΔE2000 = ΔE00 = 8.89540290019
# Testing lab(95.832, -84.89, 25.4725) vs lab(92.0, -46.0, 16.757) expects ΔE2000 = ΔE00 = 10.0987119865
# Testing lab(4.7932, 98.18, -53.6) vs lab(18.748, 113.2801, -77.818) expects ΔE2000 = ΔE00 = 10.44221617454
# Testing lab(77.43, 96.882, -72.4) vs lab(74.6, 46.6, -39.96) expects ΔE2000 = ΔE00 = 12.00984788231
# Testing lab(7.38, 20.71, 45.1) vs lab(10.0, 9.89, 70.0) expects ΔE2000 = ΔE00 = 12.69887230169
# Testing lab(58.6, -113.0, 97.33) vs lab(46.0, -110.67, 127.066) expects ΔE2000 = ΔE00 = 13.74294878713
# Testing lab(90.0, -110.118, -16.3004) vs lab(115.97, -116.0, -20.237) expects ΔE2000 = ΔE00 = 14.5738474926
# Testing lab(120.0, -96.905, 33.7) vs lab(118.027, -37.268, 32.0) expects ΔE2000 = ΔE00 = 15.95454582868
# Testing lab(88.5, -38.5356, 39.6) vs lab(90.128, -79.9454, 114.4) expects ΔE2000 = ΔE00 = 16.4672097883
# Testing lab(49.351, -31.2, 83.789) vs lab(28.8, -36.64, 89.1539) expects ΔE2000 = ΔE00 = 17.94766467288
# Testing lab(37.29, -76.839, 98.006) vs lab(23.06, -86.0, 43.12) expects ΔE2000 = ΔE00 = 18.89049392049
# Testing lab(87.309, 1.499, -63.8) vs lab(94.565, 26.5, -56.3302) expects ΔE2000 = ΔE00 = 19.65855380293
# Testing lab(61.0, 110.5483, 109.29) vs lab(42.0, 89.0, 112.0286) expects ΔE2000 = ΔE00 = 20.25440747086
# Testing lab(47.337, 48.3466, -25.049) vs lab(56.0, 97.208, 14.8) expects ΔE2000 = ΔE00 = 21.59345701271
# Testing lab(107.1, 42.1, -118.627) vs lab(126.0, 0.8969, -14.05) expects ΔE2000 = ΔE00 = 22.8577254775
# Testing lab(39.0, -92.0, 108.5292) vs lab(14.21, -83.9, 46.8) expects ΔE2000 = ΔE00 = 23.18630912723
# Testing lab(5.2, 63.1, -56.6924) vs lab(13.186, 127.362, -1.1516) expects ΔE2000 = ΔE00 = 24.31934163904
# Testing lab(27.0, 39.565, -15.5) vs lab(69.7, 123.883, -122.6755) expects ΔE2000 = ΔE00 = 49.42258355089
# Testing lab(12.232, 28.3, 66.0) vs lab(55.5533, -116.1, 7.9371) expects ΔE2000 = ΔE00 = 68.2128412982
# Testing lab(121.0, -107.53, -64.4291) vs lab(8.9029, -91.36, -99.54) expects ΔE2000 = ΔE00 = 92.81935064677
# Testing lab(124.7691, -29.8717, 82.52) vs lab(13.06, -122.0, -114.4016) expects ΔE2000 = ΔE00 = 108.33947635605
# Testing lab(20.0979, -118.76, -72.5) vs lab(117.3548, 102.9, -25.5) expects ΔE2000 = ΔE00 = 144.61949405486
