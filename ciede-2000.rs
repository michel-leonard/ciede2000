// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

use std::f64::consts::PI;

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
fn ciede_2000(l_1: f64, a_1: f64, b_1: f64, l_2: f64, a_2: f64, b_2: f64) -> f64 {
	// Working with the CIEDE2000 color-difference formula.
	// K_L, K_C, K_H are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const K_L: f64 = 1.0;
	const K_C: f64 = 1.0;
	const K_H: f64 = 1.0;
	let mut n = (a_1.hypot(b_1) + a_2.hypot(b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - (n / (n + 6103515625.0)).sqrt());
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	let c_1: f64 = (a_1 * n).hypot(b_1);
	let c_2: f64 = (a_2 * n).hypot(b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let mut h_1 = b_1.atan2(a_1 * n);
	let mut h_2 = b_2.atan2(a_2 * n);
	if h_1 < 0.0 { h_1 += 2.0 * PI; }
	if h_2 < 0.0 { h_2 += 2.0 * PI; }
	n = (h_2 - h_1).abs();
	// Cross-implementation consistent rounding.
	 if (PI - 1e-14..=PI + 1e-14).contains(&n) { n = PI; }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let mut h_m = (h_1 + h_2) * 0.5;
	let mut h_d = (h_2 - h_1) * 0.5;
	if PI < n {
		if 0.0 < h_d { h_d -= PI; }
		else { h_d += PI; }
		h_m += PI;
	}
	let p = 36.0 * h_m - 55.0 * PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	let r_t = -2.0 * (n / (n + 6103515625.0)).sqrt() * (PI / 3.0 * (p * p / (-25.0 * PI * PI)).exp()).sin();
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	let l = (l_2 - l_1) / (K_L * (1.0 + 0.015 * n / (20.0 + n).sqrt()));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	let t = 1.0 	+ 0.24 * (2.0 * h_m + PI * 0.5).sin()
			+ 0.32 * (3.0 * h_m + 8.0 * PI / 15.0).sin()
			- 0.17 * (h_m + PI / 3.0).sin()
			- 0.20 * (4.0 * h_m + 3.0 * PI / 20.0).sin();
	n = c_1 + c_2;
	// Hue.
	let h = 2.0 * (c_1 * c_2).sqrt() * (h_d).sin() / (K_H * (1.0 + 0.0075 * n * t));
	// Chroma.
	let c = (c_2 - c_1) / (K_C * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	(l * l + h * h + c * c + c * h * r_t).sqrt()
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 67.8022        a1 = 93.9           b1 = -44.62
// L2 = 67.8022        a2 = 94.0           b2 = -44.62
// CIE ΔE2000 = ΔE00 = 0.02099713142

// L1 = 82.613         a1 = 61.185         b1 = -63.44
// L2 = 82.613         a2 = 61.185         b2 = -63.2394
// CIE ΔE2000 = ΔE00 = 0.07555186291

// L1 = 91.0           a1 = -115.605       b1 = 69.511
// L2 = 91.0           a2 = -122.9404      b2 = 72.838
// CIE ΔE2000 = ΔE00 = 1.12833692901

// L1 = 24.5           a1 = -0.0           b1 = 104.42
// L2 = 24.5           a2 = -8.0           b2 = 104.42
// CIE ΔE2000 = ΔE00 = 4.00802294753

// L1 = 8.0            a1 = 3.48           b1 = -90.0
// L2 = 14.89          a2 = 3.48           b2 = -85.89
// CIE ΔE2000 = ΔE00 = 4.46848948525

// L1 = 28.8           a1 = -92.2          b1 = -46.176
// L2 = 29.343         a2 = -72.435        b2 = -21.6
// CIE ΔE2000 = ΔE00 = 8.41883014253

// L1 = 34.85          a1 = -62.0          b1 = -3.13
// L2 = 16.1           a2 = -87.1          b2 = -5.6
// CIE ΔE2000 = ΔE00 = 14.93935924428

// L1 = 72.6           a1 = 63.9507        b1 = 55.51
// L2 = 49.5494        a2 = 119.78         b2 = 93.901
// CIE ΔE2000 = ΔE00 = 22.78128404642

// L1 = 91.0           a1 = 52.4           b1 = 82.887
// L2 = 80.271         a2 = 4.225          b2 = 55.0662
// CIE ΔE2000 = ΔE00 = 24.35571360795

// L1 = 16.618         a1 = -84.8          b1 = 10.0
// L2 = 34.2           a2 = 5.0            b2 = -103.6666
// CIE ΔE2000 = ΔE00 = 48.31630637115
