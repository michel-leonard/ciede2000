// This function written in Go is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

package main

import "math"

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
func ciede_2000(l_1 float64, a_1 float64, b_1 float64, l_2 float64, a_2 float64, b_2 float64) float64 {
	// Working with the CIEDE2000 color-difference formula.
	const (
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		k_l = 1.0
		k_c = 1.0
		k_h = 1.0
	)
	n := (math.Hypot(a_1, b_1) + math.Hypot(a_2, b_2)) * 0.5
	n = n * n * n * n * n * n * n
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - math.Sqrt(n / (n + 6103515625.0)))
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 := math.Hypot(a_1 * n, b_1)
	c_2 := math.Hypot(a_2 * n, b_2)
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 := math.Atan2(b_1, a_1 * n)
	h_2 := math.Atan2(b_2, a_2 * n)
	if h_1 < 0.0 { h_1 += 2.0 * math.Pi }
	if h_2 < 0.0 { h_2 += 2.0 * math.Pi }
	n = math.Abs(h_2 - h_1)
	// Cross-implementation consistent rounding.
	if math.Pi - 1E-14 < n && n < math.Pi + 1E-14 { n = math.Pi }
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	h_m := (h_1 + h_2) * 0.5
	h_d := (h_2 - h_1) * 0.5
	if math.Pi < n {
		if 0.0 < h_d { h_d -= math.Pi } else { h_d += math.Pi }
		h_m += math.Pi
	}
	p := 36.0 * h_m - 55.0 * math.Pi
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	r_t :=	-2.0 * math.Sqrt(n / (n + 6103515625.0)) *
			math.Sin(math.Pi / 3.0 * math.Exp(p * p / (-25.0 * math.Pi * math.Pi)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	// Lightness.
	l := (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / math.Sqrt(20.0 + n)))
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	t := 1.0 +	0.24 * math.Sin(2.0 * h_m + math.Pi * 0.5) +
			0.32 * math.Sin(3.0 * h_m + 8.0 * math.Pi / 15.0) -
			0.17 * math.Sin(h_m + math.Pi / 3.0) -
			0.20 * math.Sin(4.0 * h_m + 3.0 * math.Pi / 20.0)
	n = c_1 + c_2
	// Hue.
	h := 2.0 * math.Sqrt(c_1 * c_2) * math.Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	// Chroma.
	c := (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return math.Sqrt(l * l + h * h + c * c + c * h * r_t)
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 23.2081        a1 = 68.62          b1 = 73.3
// L2 = 23.2081        a2 = 68.62          b2 = 73.3423
// CIE ΔE2000 = ΔE00 = 0.01546020364

// L1 = 17.66          a1 = 7.8355         b1 = 94.1297
// L2 = 17.66          a2 = 7.524          b2 = 103.6
// CIE ΔE2000 = ΔE00 = 1.81121174912

// L1 = 18.0           a1 = 117.0          b1 = 64.0
// L2 = 18.0           a2 = 122.249        b2 = 60.84
// CIE ΔE2000 = ΔE00 = 1.99022140872

// L1 = 92.5732        a1 = -8.71          b1 = -114.34
// L2 = 99.8           a2 = -8.71          b2 = -114.34
// CIE ΔE2000 = ΔE00 = 4.27729128854

// L1 = 4.6495         a1 = 57.5           b1 = -52.142
// L2 = 9.8849         a2 = 74.4788        b2 = -92.0
// CIE ΔE2000 = ΔE00 = 11.09285729741

// L1 = 12.0           a1 = 42.985         b1 = 110.2125
// L2 = 4.44           a2 = 5.647          b2 = 81.08
// CIE ΔE2000 = ΔE00 = 17.82293094338

// L1 = 49.36          a1 = -102.421       b1 = 69.8
// L2 = 56.693         a2 = -111.61        b2 = -47.6
// CIE ΔE2000 = ΔE00 = 40.96412610481

// L1 = 34.33          a1 = -109.21        b1 = -64.36
// L2 = 86.2201        a2 = 17.64          b2 = 43.375
// CIE ΔE2000 = ΔE00 = 71.26247346036

// L1 = 21.284         a1 = 111.0          b1 = 71.0
// L2 = 60.0           a2 = -63.8288       b2 = -103.9
// CIE ΔE2000 = ΔE00 = 99.63603049737

// L1 = 43.7           a1 = -109.5384      b1 = -26.098
// L2 = 61.94          a2 = 65.4           b2 = 2.2803
// CIE ΔE2000 = ΔE00 = 111.40944865813
