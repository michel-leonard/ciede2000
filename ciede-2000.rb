# This function written in Ruby is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
def ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	# Working with the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l = k_c = k_h = 1.0
	n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)))
	# hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = Math.hypot(a_1 * n, b_1)
	c_2 = Math.hypot(a_2 * n, b_2)
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = Math.atan2(b_1, a_1 * n)
	h_2 = Math.atan2(b_2, a_2 * n)
	h_1 += 2.0 * Math::PI if h_1 < 0.0
	h_2 += 2.0 * Math::PI if h_2 < 0.0
	n = (h_2 - h_1).abs
	# Cross-implementation consistent rounding.
	n = Math::PI if Math::PI - 1E-14 < n && n < Math::PI + 1E-14
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = 0.5 * h_1 + 0.5 * h_2
	h_d = (h_2 - h_1) * 0.5
	if Math::PI < n
		if 0.0 < h_d
			h_d -= Math::PI
		else
			h_d += Math::PI
		end
		h_m += Math::PI
	end
	p = (36.0 * h_m - 55.0 * Math::PI)
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0)) \
		* Math.sin(Math::PI / 3.0 * Math.exp(p * p / (-25.0 * Math::PI * Math::PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math::PI / 2.0) \
		+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math::PI / 15.0) \
		- 0.17 * Math.sin(h_m + Math::PI / 3.0) \
		- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math::PI / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returning the square root ensures that the result represents
	# the "true" geometric distance in the color space.
	Math.sqrt(l * l + h * h + c * c + c * h * r_t)
end

#
# More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
#
# Testing lab(17.427, 73.3, 67.04) vs lab(17.427, 73.3, 67.04) expects ΔE2000 = ΔE00 = 0.0
# Testing lab(28.6941, 78.81, -77.0) vs lab(28.712, 78.81, -77.0) expects ΔE2000 = ΔE00 = 0.01363668556
# Testing lab(125.087, 99.15, 106.71) vs lab(125.087, 99.15, 106.8) expects ΔE2000 = ΔE00 = 0.02641651055
# Testing lab(63.7298, -77.55, -123.8) vs lab(63.7809, -77.55, -124.1) expects ΔE2000 = ΔE00 = 0.06295299519
# Testing lab(94.1408, 112.2509, 10.258) vs lab(94.0, 112.2509, 10.258) expects ΔE2000 = ΔE00 = 0.08493806666
# Testing lab(30.96, -119.16, -72.0) vs lab(30.96, -119.16, -72.4969) expects ΔE2000 = ΔE00 = 0.1233905061
# Testing lab(28.09, -93.0, 86.7003) vs lab(28.09, -91.186, 87.3522) expects ΔE2000 = ΔE00 = 0.49894657369
# Testing lab(26.0, 60.3, -5.003) vs lab(26.0, 60.3, -3.145) expects ΔE2000 = ΔE00 = 0.82554438398
# Testing lab(62.0504, 47.8, -118.62) vs lab(62.0504, 47.8, -116.0) expects ΔE2000 = ΔE00 = 0.85312273868
# Testing lab(95.98, 116.0, 28.432) vs lab(95.98, 109.0, 28.432) expects ΔE2000 = ΔE00 = 1.24631688073
# Testing lab(24.75, -125.0, 116.949) vs lab(24.75, -125.0, 125.6) expects ΔE2000 = ΔE00 = 1.53500336448
# Testing lab(77.16, 99.9689, 115.797) vs lab(77.16, 106.0, 115.797) expects ΔE2000 = ΔE00 = 1.84773527814
# Testing lab(12.05, 101.885, 12.725) vs lab(15.0, 101.885, 12.725) expects ΔE2000 = ΔE00 = 1.91178767153
# Testing lab(73.07, 109.57, -115.9256) vs lab(73.07, 100.7623, -115.0) expects ΔE2000 = ΔE00 = 2.17975541441
# Testing lab(11.48, -118.0, -76.4306) vs lab(15.4, -118.0, -76.4306) expects ΔE2000 = ΔE00 = 2.53829682581
# Testing lab(39.278, -54.07, -9.0) vs lab(39.278, -47.88, -5.1986) expects ΔE2000 = ΔE00 = 2.62271360083
# Testing lab(62.0, -25.22, -36.5) vs lab(62.0, -32.8, -38.6309) expects ΔE2000 = ΔE00 = 3.0864219346
# Testing lab(66.0, 125.3, 43.4) vs lab(68.0, 123.345, 34.5) expects ΔE2000 = ΔE00 = 3.18682401675
# Testing lab(83.34, 56.8977, 91.0) vs lab(87.159, 56.8977, 99.82) expects ΔE2000 = ΔE00 = 3.58246942295
# Testing lab(121.0, 107.4075, -47.0) vs lab(127.7, 107.4075, -54.2479) expects ΔE2000 = ΔE00 = 3.73719231073
# Testing lab(84.787, -7.3385, 87.0) vs lab(84.787, -15.0, 87.0) expects ΔE2000 = ΔE00 = 3.99820153937
# Testing lab(15.5, -42.0, -55.57) vs lab(15.5, -47.7, -45.887) expects ΔE2000 = ΔE00 = 4.21450230851
# Testing lab(66.4462, 49.0, -8.2) vs lab(68.6, 49.0, -17.143) expects ΔE2000 = ΔE00 = 4.51282291193
# Testing lab(80.39, 36.471, -28.427) vs lab(85.8584, 36.471, -22.7) expects ΔE2000 = ΔE00 = 4.66385883037
# Testing lab(74.1, 67.76, -24.0) vs lab(75.06, 52.15, -26.5422) expects ΔE2000 = ΔE00 = 4.98385678119
# Testing lab(77.4434, 36.0, -113.0) vs lab(78.4, 26.73, -115.02) expects ΔE2000 = ΔE00 = 5.61180695942
# Testing lab(92.7, -51.3753, 77.2) vs lab(98.424, -72.0, 88.1) expects ΔE2000 = ΔE00 = 6.14164520204
# Testing lab(97.1793, 41.2981, 19.06) vs lab(97.0, 65.6, 31.467) expects ΔE2000 = ΔE00 = 7.46784069663
# Testing lab(38.33, 98.0, 72.5) vs lab(39.109, 86.317, 89.5099) expects ΔE2000 = ΔE00 = 8.95947170128
# Testing lab(62.426, -13.6549, 13.6563) vs lab(72.0, -7.5, 7.5) expects ΔE2000 = ΔE00 = 9.63805781598
# Testing lab(65.9, 101.1872, 125.3341) vs lab(62.56, 102.8, 91.52) expects ΔE2000 = ΔE00 = 10.59234409758
# Testing lab(39.573, 5.0, 84.0) vs lab(47.767, -7.0, 113.08) expects ΔE2000 = ΔE00 = 11.16630362514
# Testing lab(73.0, 37.363, -82.812) vs lab(73.161, 84.0, -117.056) expects ΔE2000 = ΔE00 = 12.27109490047
# Testing lab(4.2, 70.8991, 88.3) vs lab(23.33, 86.5556, 89.78) expects ΔE2000 = ΔE00 = 13.49600751955
# Testing lab(27.8, -78.844, 71.4) vs lab(42.3077, -98.0, 48.3) expects ΔE2000 = ΔE00 = 15.08902572659
# Testing lab(20.0, -126.53, 122.122) vs lab(22.993, -51.0, 103.9023) expects ΔE2000 = ΔE00 = 15.83673320848
# Testing lab(3.242, 91.3, 0.877) vs lab(28.0, 84.0, 12.0) expects ΔE2000 = ΔE00 = 17.01029665315
# Testing lab(50.0, -78.0, -21.0) vs lab(39.89, -28.86, -5.23) expects ΔE2000 = ΔE00 = 17.76792451734
# Testing lab(58.85, 26.539, 61.0) vs lab(76.579, 19.9, 27.0) expects ΔE2000 = ΔE00 = 18.82246013094
# Testing lab(48.8, 81.5502, -81.0) vs lab(61.6346, 30.31, -57.0) expects ΔE2000 = ΔE00 = 19.74213717749
# Testing lab(27.43, -84.54, 18.181) vs lab(46.8, -106.2, 63.493) expects ΔE2000 = ΔE00 = 20.84092799092
# Testing lab(93.0, 107.7, -45.871) vs lab(90.2, 49.3, -69.117) expects ΔE2000 = ΔE00 = 21.67988081014
# Testing lab(85.314, 123.1384, -23.15) vs lab(81.6, 103.78, -103.8387) expects ΔE2000 = ΔE00 = 22.14269042326
# Testing lab(19.72, 55.0, -54.1) vs lab(0.9, 22.171, -4.0793) expects ΔE2000 = ΔE00 = 24.01510504513
# Testing lab(85.3, 43.71, 17.0) vs lab(76.1894, 23.1428, -23.0) expects ΔE2000 = ΔE00 = 24.27393682373
# Testing lab(45.0, 84.092, 109.0) vs lab(7.0, 58.75, 1.8338) expects ΔE2000 = ΔE00 = 46.58165317888
# Testing lab(13.0, 25.725, 99.0) vs lab(3.9, 12.0, -41.8) expects ΔE2000 = ΔE00 = 54.97400756062
# Testing lab(17.0, -52.84, -78.0098) vs lab(40.855, 111.276, 66.401) expects ΔE2000 = ΔE00 = 93.81669416251
# Testing lab(71.1722, -124.0, 57.77) vs lab(34.6, 118.0, -9.0) expects ΔE2000 = ΔE00 = 124.03458923201
# Testing lab(20.14, -114.0, 105.029) vs lab(110.398, 117.08, -107.0) expects ΔE2000 = ΔE00 = 142.97374598708
