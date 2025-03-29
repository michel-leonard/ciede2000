# This function written in Ruby is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

# The classic CIE ΔE implementation, ΔE2000 (ΔE00).
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
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if Math::PI < n
		if 0.0 < h_d
			h_d -= Math::PI
		else
			h_d += Math::PI
		end
		h_m += Math::PI
	end
	p = 36.0 * h_m - 55.0 * Math::PI
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
	t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math::PI * 0.5) \
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

# GitHub Project : https://github.com/michel-leonard/ciede2000
#  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

# L1 = 31.49          a1 = 7.59           b1 = -18.7
# L2 = 31.52          a2 = 7.59           b2 = -18.7
# CIE ΔE2000 = ΔE00 = 0.0236284872

# L1 = 49.2           a1 = 14.0           b1 = -8.377
# L2 = 49.2           a2 = 13.9422        b2 = -8.377
# CIE ΔE2000 = ΔE00 = 0.04377911119

# L1 = 84.2           a1 = 69.85          b1 = 62.7271
# L2 = 88.7           a2 = 69.85          b2 = 62.7271
# CIE ΔE2000 = ΔE00 = 2.91700033454

# L1 = 6.0            a1 = 78.0           b1 = -7.9139
# L2 = 6.0            a2 = 78.0           b2 = -16.7952
# CIE ΔE2000 = ΔE00 = 3.27295600712

# L1 = 24.6677        a1 = 114.29         b1 = -41.922
# L2 = 30.5           a2 = 122.969        b2 = -48.9
# CIE ΔE2000 = ΔE00 = 4.75258771065

# L1 = 23.9           a1 = -18.25         b1 = 103.0
# L2 = 18.976         a2 = -5.3           b2 = 94.9
# CIE ΔE2000 = ΔE00 = 7.06901211741

# L1 = 81.755         a1 = 92.0           b1 = -66.756
# L2 = 85.57          a2 = 112.59         b2 = -51.59
# CIE ΔE2000 = ΔE00 = 7.81146131552

# L1 = 81.7           a1 = 67.76          b1 = -125.6
# L2 = 74.352         a2 = -5.5           b2 = -16.4
# CIE ΔE2000 = ΔE00 = 14.59489131316

# L1 = 55.661         a1 = 9.7155         b1 = 39.5
# L2 = 71.669         a2 = 19.37          b2 = -34.1
# CIE ΔE2000 = ΔE00 = 45.48145580317

# L1 = 43.0           a1 = 19.81          b1 = 0.4
# L2 = 93.0           a2 = -27.0          b2 = -71.194
# CIE ΔE2000 = ΔE00 = 66.21097676357
