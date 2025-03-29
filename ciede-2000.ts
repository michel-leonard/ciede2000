// This function written in TypeScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
function ciede_2000(l_1: number, a_1: number, b_1: number, l_2: number, a_2: number, b_2: number): number {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const k_l = 1.0, k_c = 1.0, k_h = 1.0;
	let n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * Math.PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * Math.PI;
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let h_m = (h_1 + h_2) * 0.5, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	const p = 36.0 * h_m - 55.0 * Math.PI;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
		* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const t = 1.0	+ 0.24 * Math.sin(2.0 * h_m + Math.PI * 0.5)
			+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
			- 0.17 * Math.sin(h_m + Math.PI / 3.0)
			- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 47.631         a1 = -42.922        b1 = 73.0
// L2 = 47.631         a2 = -42.922        b2 = 72.982
// CIE ΔE2000 = ΔE00 = 0.00499141439

// L1 = 21.124         a1 = -66.0          b1 = -112.75
// L2 = 21.124         a2 = -66.3886       b2 = -112.9546
// CIE ΔE2000 = ΔE00 = 0.08424435676

// L1 = 58.9           a1 = 71.64          b1 = -75.85
// L2 = 61.851         a2 = 71.64          b2 = -75.85
// CIE ΔE2000 = ΔE00 = 2.58197986112

// L1 = 1.4            a1 = 58.767         b1 = 97.47
// L2 = 7.8            a2 = 58.767         b2 = 97.47
// CIE ΔE2000 = ΔE00 = 3.81470116074

// L1 = 3.48           a1 = -68.534        b1 = 10.548
// L2 = 3.48           a2 = -66.5          b2 = 20.4
// CIE ΔE2000 = ΔE00 = 4.56568072554

// L1 = 86.0           a1 = -106.94        b1 = -124.2898
// L2 = 79.21          a2 = -122.0         b2 = -127.1411
// CIE ΔE2000 = ΔE00 = 5.15640910635

// L1 = 3.4            a1 = 92.618         b1 = -47.3376
// L2 = 14.367         a2 = 83.1           b2 = -30.0
// CIE ΔE2000 = ΔE00 = 8.43457855659

// L1 = 3.289          a1 = -48.0          b1 = 64.9463
// L2 = 16.293         a2 = -49.3          b2 = 100.602
// CIE ΔE2000 = ΔE00 = 11.98560043246

// L1 = 77.0           a1 = -108.8         b1 = -103.2992
// L2 = 78.7           a2 = -44.909        b2 = -16.3
// CIE ΔE2000 = ΔE00 = 22.34093785594

// L1 = 97.0           a1 = -123.156       b1 = 7.9
// L2 = 95.0           a2 = -92.6          b2 = 89.17
// CIE ΔE2000 = ΔE00 = 24.91486611182
