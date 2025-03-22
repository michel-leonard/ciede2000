// This function written in JavaScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2) {
	"use strict"
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	var k_l = 1.0, k_c = 1.0, k_h = 1.0;
	var n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	var c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	var h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	h_1 += 2.0 * Math.PI * (h_1 < 0.0);
	h_2 += 2.0 * Math.PI * (h_2 < 0.0);
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	var h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	var p = (36.0 * h_m - 55.0 * Math.PI);
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	var r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
					* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	var l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	var t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math.PI / 2)
				+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
				- 0.17 * Math.sin(h_m + Math.PI / 3.0)
				- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	var h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	var c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}


class Xorshift {
    constructor(seed) {
		this.state = BigInt(seed) ^ 0xff51afd7ed558ccdn;
		this.next()
    }

    next() {
        this.state ^= (this.state << 13n) & 0xFFFFFFFFFFFFFFFFn;
        this.state ^= (this.state >> 7n) & 0xFFFFFFFFFFFFFFFFn;
        this.state ^= (this.state << 17n) & 0xFFFFFFFFFFFFFFFFn;
        return this.state & 0xFFFFFFFFFFFFFFFFn;
    }

    nextFloat(min, max) {
        return min + (Number(this.next()) / Number(0xFFFFFFFFFFFFFFFFn)) * (max - min);
    }

    nextBool() {
        return (this.next() & 1n) === 1n;
    }
}

function get_lab_colors(rng) {
	const values = [ rng.nextFloat(0, 100), rng.nextFloat(-128, 128), rng.nextFloat(-128, 128), rng.nextFloat(0, 100), rng.nextFloat(-128, 128), rng.nextFloat(-128, 128) ]
	for(let j = 0; j < 6; ++j) {
		if(3 < j && rng.nextBool())
			values[j] = rng.nextBool() ? values[j - 3] : -values[j - 3]
		if (rng.nextBool())
			values[j] = Math.round(values[j])
		else if(rng.nextBool())
			values[j] = Math.round(10.0 * values[j]) / 10.0
	}
    return values
}

// Use the sequence 123 for this example
rng = new Xorshift(123)

for(let i = 1; i < 10; ++i) {
	const [L1, a1, b1, L2, a2, b2] = get_lab_colors(rng)
	const deltaE = ciede_2000(L1, a1, b1, L2, a2, b2)
	console.log(i + ". DeltaE2000=" + deltaE + " when L1=" + L1 + ", a1=" + a1 + ", b1=" + b1 + ", L2=" + L2 + ", a2=" + a2 + ", b2=" + b2)
}
