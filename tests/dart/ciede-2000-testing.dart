// This function written in Dart is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import 'dart:math';

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
double ciede_2000(double l_1, double a_1, double b_1, double l_2, double a_2, double b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// Since hypot is not available, sqrt is used here to calculate the
	// Euclidean distance, without avoiding overflow/underflow.
	final double c_1 = sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	final double c_2 = sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	if (h_1 < 0.0) h_1 += 2.0 * pi;
	if (h_2 < 0.0) h_2 += 2.0 * pi;
	n = (h_2 - h_1).abs();
	// Cross-implementation consistent rounding.
	if (pi - 1E-14 < n && n < pi + 1E-14)
		n = pi;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (pi < n) {
		if (0.0 < h_d)
			h_d -= pi;
		else
			h_d += pi;
		h_m += pi;
	}
	final double p = 36.0 * h_m - 55.0 * pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	final double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	final double t = 1.0 	+ 0.24 * sin(2.0 * h_m + pi * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0)
				- 0.17 * sin(h_m + pi / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
	n = c_1 + c_2;
	// Hue.
	final double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

double my_round(double valeur) {
  Random random = Random();
  if (random.nextBool()) {
    return double.parse(valeur.toStringAsFixed(0));
  } else {
    return double.parse(valeur.toStringAsFixed(1));
  }
}

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000/batch.html
void main() {
	Random random = Random();

	for (int i = 0; i < 10000; i++) {
	double l1 = random.nextDouble() * 100;
	double a1 = random.nextDouble() * 256 - 128;
	double b1 = random.nextDouble() * 256 - 128;
	double l2 = random.nextDouble() * 100;
	double a2 = random.nextDouble() * 256 - 128;
	double b2 = random.nextDouble() * 256 - 128;

	l1 = my_round(l1);
	a1 = my_round(a1);
	b1 = my_round(b1);
	l2 = my_round(l2);
	a2 = my_round(a2);
	b2 = my_round(b2);

	double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);

	print('$l1,$a1,$b1,$l2,$a2,$b2,$deltaE');
  }
}
