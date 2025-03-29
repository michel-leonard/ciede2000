# This function written in Julia is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

using Base.MathConstants
using LinearAlgebra

# The classic CIE ΔE implementation, ΔE2000 (ΔE00).
function ciede_2000(l_1::Float64, a_1::Float64, b_1::Float64, l_2::Float64, a_2::Float64, b_2::Float64)::Float64
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
	h_1 = atan(b_1, a_1 * n)
	h_2 = atan(b_2, a_2 * n)
	h_1 += 2.0 * π * (h_1 < 0.0)
	h_2 += 2.0 * π * (h_2 < 0.0)
	n = abs(h_2 - h_1)
	# Cross-implementation consistent rounding.
	if π - 1E-14 < n && n < π + 1E-14
		n = π
	end
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	if π < n
		if (0.0 < h_d)
			h_d -= π
		else
			h_d += π
		end
		h_m += π
	end
	p = 36.0 * h_m - 55.0 * π
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n / (n + 6103515625.0)) *
			sin(π / 3.0 * exp(p * p / (-25.0 * π * π)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	# Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)))
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t = 1.0	+ 0.24 * sin(2.0 * h_m + π * 0.5) +
		0.32 * sin(3.0 * h_m + 8.0 * π / 15.0) -
		0.17 * sin(h_m + π / 3.0) -
		0.20 * sin(4.0 * h_m + 3.0 * π / 20.0)
	n = c_1 + c_2
	# Hue.
	h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	# Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	# Returning the square root ensures that the result represents
	# the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t)
end

# GitHub Project : https://github.com/michel-leonard/ciede2000
#  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

# L1 = 76.0           a1 = -22.048        b1 = -100.198
# L2 = 76.0           a2 = -22.048        b2 = -100.28
# CIE ΔE2000 = ΔE00 = 0.01159614815

# L1 = 92.202         a1 = 25.004         b1 = -31.5386
# L2 = 92.202         a2 = 25.004         b2 = -31.6
# CIE ΔE2000 = ΔE00 = 0.03462877029

# L1 = 83.0           a1 = -60.8569       b1 = 30.0
# L2 = 87.3           a2 = -60.8569       b2 = 22.028
# CIE ΔE2000 = ΔE00 = 4.3317391477

# L1 = 92.0           a1 = -76.52         b1 = 107.6201
# L2 = 90.5           a2 = -72.0839       b2 = 83.3394
# CIE ΔE2000 = ΔE00 = 4.97357032318

# L1 = 9.0            a1 = 94.4           b1 = 83.6534
# L2 = 6.0            a2 = 81.2           b2 = 85.4495
# CIE ΔE2000 = ΔE00 = 5.15355674013

# L1 = 53.0           a1 = 97.34          b1 = -118.1
# L2 = 55.0           a2 = 70.4           b2 = -105.6479
# CIE ΔE2000 = ΔE00 = 6.80128610855

# L1 = 95.0588        a1 = 88.2399        b1 = 41.96
# L2 = 91.028         a2 = 113.3          b2 = 77.285
# CIE ΔE2000 = ΔE00 = 9.99292492242

# L1 = 64.956         a1 = 86.71          b1 = -36.042
# L2 = 70.63          a2 = 117.0          b2 = -75.75
# CIE ΔE2000 = ΔE00 = 10.62469780526

# L1 = 57.0           a1 = 112.1          b1 = 34.7543
# L2 = 58.64          a2 = 105.0          b2 = -4.8548
# CIE ΔE2000 = ΔE00 = 13.06849997391

# L1 = 74.0           a1 = -40.914        b1 = 112.831
# L2 = 87.73          a2 = -33.0          b2 = 52.1322
# CIE ΔE2000 = ΔE00 = 16.76842852198


# The output is intended to be checked by the Large-Scale validator
# at https://michel-leonard.github.io/ciede2000/batch.html

using Random

iterations = 10000

for _ in 1:iterations
	l_1 = round(rand() * 100, digits=rand([0, 1]))
	a_1 = round((rand() * 256) - 128, digits=rand([0, 1]))
	b_1 = round((rand() * 256) - 128, digits=rand([0, 1]))

	l_2 = round(rand() * 100, digits=rand([0, 1]))
	a_2 = round((rand() * 256) - 128, digits=rand([0, 1]))
	b_2 = round((rand() * 256) - 128, digits=rand([0, 1]))

	delta = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)

	println("$l_1,$a_1,$b_1,$l_2,$a_2,$b_2,$delta")
end
