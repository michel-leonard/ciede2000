# This function written in Python is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE implementation, ΔE2000 (ΔE00).
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
	if pi - 1E-14 < n and n < pi + 1E-14 :
		n = pi
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if pi < n :
		if (0.0 < h_d) :
			h_d -= pi
		else :
			h_d += pi
		h_m += pi
	p = 36.0 * h_m - 55.0 * pi
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
	t = 1.0	+ 0.24 * sin(2.0 * h_m + pi * 0.5) \
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

# GitHub Project : https://github.com/michel-leonard/ciede2000
#  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

# L1 = 33.0           a1 = 56.551         b1 = 107.34
# L2 = 33.0           a2 = 56.551         b2 = 107.41
# CIE ΔE2000 = ΔE00 = 0.0182199484

# L1 = 57.751         a1 = -64.8572       b1 = 104.6669
# L2 = 57.751         a2 = -65.0          b2 = 104.6669
# CIE ΔE2000 = ΔE00 = 0.04105095889

# L1 = 51.2347        a1 = -53.74         b1 = -85.6
# L2 = 51.2347        a2 = -54.0          b2 = -85.6
# CIE ΔE2000 = ΔE00 = 0.07251289185

# L1 = 27.5           a1 = -38.963        b1 = 102.02
# L2 = 27.5           a2 = -39.0          b2 = 101.6285
# CIE ΔE2000 = ΔE00 = 0.09222135798

# L1 = 58.207         a1 = -105.0         b1 = -79.71
# L2 = 58.207         a2 = -106.2         b2 = -79.71
# CIE ΔE2000 = ΔE00 = 0.23933030702

# L1 = 18.6           a1 = 5.4            b1 = 81.0
# L2 = 18.6           a2 = 5.4            b2 = 90.0
# CIE ΔE2000 = ΔE00 = 1.87770163489

# L1 = 32.913         a1 = 3.0961         b1 = 115.117
# L2 = 32.913         a2 = 8.4101         b2 = 115.117
# CIE ΔE2000 = ΔE00 = 2.60306648026

# L1 = 49.0           a1 = -12.0          b1 = 124.282
# L2 = 53.0           a2 = -12.0          b2 = 116.703
# CIE ΔE2000 = ΔE00 = 4.16877634871

# L1 = 21.032         a1 = -30.4          b1 = -68.783
# L2 = 26.0           a2 = -14.9          b2 = -54.29
# CIE ΔE2000 = ΔE00 = 8.23700340366

# L1 = 76.5           a1 = -83.7311       b1 = 10.0
# L2 = 97.08          a2 = -59.472        b2 = 28.1
# CIE ΔE2000 = ΔE00 = 17.25538447747
