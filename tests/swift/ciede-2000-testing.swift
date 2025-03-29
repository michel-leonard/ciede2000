// This function written in Swift is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

import Foundation

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
func ciede_2000(l_1: Double, a_1: Double, b_1: Double, l_2: Double, a_2: Double, b_2: Double) -> Double {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	let k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	let c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	if h_1 < 0.0 { h_1 += 2.0 * .pi; }
	if h_2 < 0.0 { h_2 += 2.0 * .pi; }
	n = abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if .pi - 1E-14 < n && n < .pi + 1E-14 { n = .pi; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if .pi < n {
		if 0.0 < h_d { h_d -= .pi; }
		else { h_d += .pi; }
		h_m += .pi;
	}
	let p = 36.0 * h_m - 55.0 * .pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(.pi / 3.0 * exp(p * p / (-25.0 * .pi * .pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0 	+ 0.24 * sin(2.0 * h_m + .pi * 0.5)
				+ 0.32 * sin(3.0 * h_m + 8.0 * .pi / 15.0)
				- 0.17 * sin(h_m + .pi / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * .pi / 20.0);
	n = c_1 + c_2;
	// Hue.
	let h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

// The output is intended to be checked by the Large-Scale validator
// at https://michel-leonard.github.io/ciede2000/batch.html

var results: [String] = []

for _ in 0..<10000 {
	let l1Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let l1 = round(Double.random(in: 0...100) * l1Decimal) / l1Decimal
	let a1Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let a1 = round(Double.random(in: -128...128) * a1Decimal) / a1Decimal
	let b1Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let b1 = round(Double.random(in: -128...128) * b1Decimal) / b1Decimal

	let l2Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let l2 = round(Double.random(in: 0...100) * l2Decimal) / l2Decimal
	let a2Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let a2 = round(Double.random(in: -128...128) * a2Decimal) / a2Decimal
	let b2Decimal = pow(10.0, Double(Int.random(in: 0...1)))
	let b2 = round(Double.random(in: -128...128) * b2Decimal) / b2Decimal

	let deltaE = ciede_2000(l_1: l1, a_1: a1, b_1: b1, l_2: l2, a_2: a2, b_2: b2)
	
	results.append("\(l1),\(a1),\(b1),\(l2),\(a2),\(b2),\(deltaE)")
}

for result in results {
	print(result)
}
