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

# GitHub Project : https://github.com/michel-leonard/ciede2000
#  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

# L1 = 46.9           a1 = -28.6          b1 = -83.9225
# L2 = 46.9           a2 = -28.6          b2 = -84.0
# CIE ΔE2000 = ΔE00 = 0.01373051044

# L1 = 69.86          a1 = 49.3           b1 = -50.2
# L2 = 69.86          a2 = 49.3           b2 = -50.0
# CIE ΔE2000 = ΔE00 = 0.08485174021

# L1 = 96.0           a1 = -77.0          b1 = 100.578
# L2 = 96.34          a2 = -77.0          b2 = 100.578
# CIE ΔE2000 = ΔE00 = 0.20126395883

# L1 = 20.7432        a1 = -63.83         b1 = -24.8
# L2 = 20.7432        a2 = -55.77         b2 = -25.0
# CIE ΔE2000 = ΔE00 = 2.4756185438

# L1 = 81.8719        a1 = 84.49          b1 = -74.7
# L2 = 85.3           a2 = 78.3           b2 = -76.0
# CIE ΔE2000 = ΔE00 = 3.10501462684

# L1 = 92.1           a1 = -74.9          b1 = -92.3
# L2 = 89.0           a2 = -44.5769       b2 = -108.9
# CIE ΔE2000 = ΔE00 = 9.43581400151

# L1 = 22.8           a1 = -57.0          b1 = -97.2
# L2 = 5.23           a2 = -62.733        b2 = -62.4
# CIE ΔE2000 = ΔE00 = 14.2978099479

# L1 = 78.138         a1 = 37.28          b1 = 28.28
# L2 = 99.408         a2 = 87.5           b2 = 67.329
# CIE ΔE2000 = ΔE00 = 19.45263690952

# L1 = 33.5           a1 = -81.0113       b1 = 96.3
# L2 = 6.0092         a2 = -125.48        b2 = 107.1392
# CIE ΔE2000 = ΔE00 = 20.58506046626

# L1 = 78.0           a1 = -18.0          b1 = -76.4868
# L2 = 71.724         a2 = 15.91          b2 = 108.5913
# CIE ΔE2000 = ΔE00 = 72.22711860116

def prepare_values(num_lines = 10000):
	import csv
	import random
	filename = f"./values-py.txt"
	print(f"prepare_values('{filename}', {num_lines})")
	with open(filename, 'w') as file:
		for i in range(num_lines):
			L1 = round(random.uniform(0, 100), random.randint(0, 2))
			a1 = round(random.uniform(-128, 128), random.randint(0, 2))
			b1 = round(random.uniform(-128, 128), random.randint(0, 2))
			L2 = round(random.uniform(0, 100), random.randint(0, 2))
			a2 = round(random.uniform(-128, 128), random.randint(0, 2))
			b2 = round(random.uniform(-128, 128), random.randint(0, 2))

			if i % 1000 == 0:
				print('.', end='', flush=True)

			deltaE = ciede_2000(L1, a1, b1, L2, a2, b2)
			file.write(','.join(str(n) for n in [L1, a1, b1, L2, a2, b2, deltaE]) + '\n')


def compare_values(extension = 'py'):
	import math
	import csv
	filename = f"./../{extension}/values-{extension}.txt"
	print(f"compare_values('{filename}')")
	try:
		with open(filename, 'r') as file:
			count = -1
			reader = csv.reader(file)
			for row in reader:
				count += 1
				L1, a1, b1, L2, a2, b2, delta_e = map(float, row)
				res = ciede_2000(L1, a1, b1, L2, a2, b2)
				if not math.isfinite(res) or not math.isfinite(delta_e) or abs(res - delta_e) > 1e-10:
					print(f"Error on line {count}: expected {delta_e}, got {res}")
					break
				elif count % 1000 == 0:
					print('.', end='', flush=True)
	except FileNotFoundError:
		print(f"File {filename} not found.")


def main():
	import argparse
	parser = argparse.ArgumentParser(description="Process a number or a string.")
	parser.add_argument("input", help="Input can be a positive integer or a lowercase string.")
	args = parser.parse_args()

	input_value = args.input

	if input_value.isalpha() and len(input_value) :
		compare_values(input_value)
	else:
		try:
			number = int(input_value)
			if number < 0:
				raise ValueError("Number must be zero or positive.")
			prepare_values(number)
		except ValueError:
			print("Invalid input, using default value 10000.")
			prepare_values(10000)

if __name__ == "__main__":
	main()
