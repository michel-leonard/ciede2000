package main

import (
	"encoding/json"
	"fmt"
	"math"
)

// This function written in Go is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

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
	h_m := 0.5 * h_1 + 0.5 * h_2
	h_d := (h_2 - h_1) * 0.5
	if math.Pi < n {
		if 0.0 < h_d {
			h_d -= math.Pi
		} else {
			h_d += math.Pi
		}
		h_m += math.Pi
	}
	p := (36.0 * h_m - 55.0 * math.Pi)
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
	t := 1.0 	+ 0.24 * math.Sin(2.0 * h_m + math.Pi / 2.0) +
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

type Xorshift struct {
	state uint64
}

func NewXorshift(seed uint64) *Xorshift {
	res := &Xorshift{state: seed ^ 0xff51afd7ed558ccd}
	res.Next()
	return res
}

func (x *Xorshift) Next() uint64 {
	x.state ^= (x.state << 13)
	x.state ^= (x.state >> 7)
	x.state ^= (x.state << 17)
	return x.state
}

func (x *Xorshift) NextFloat(min, max float64) float64 {
	return min + (float64(x.Next()&0xFFFFFFFFFFFFFFFF)/float64(0xFFFFFFFFFFFFFFFF))*(max-min)
}

func (x *Xorshift) NextBool() bool {
	return (x.Next() & 1) == 1
}

func roundValue(x float64, precision int) float64 {
	if precision == 0 {
		return math.Round(x)
	} else {
		return math.Round(x * 10.0) / 10.0
	}
}

func getLabColors(rng *Xorshift) (float64, float64, float64, float64, float64, float64) {
	values := [6]float64{rng.NextFloat(0, 100), rng.NextFloat(-128, 128), rng.NextFloat(-128, 128), rng.NextFloat(0, 100), rng.NextFloat(-128, 128), rng.NextFloat(-128, 128)}
	for i := 0; i < 6; i++ {
		if 3 < i && rng.NextBool() {
			if rng.NextBool() {
				values[i] = values[i - 3]
			} else {
				values[i] = -values[i - 3]
			}
		}
		if rng.NextBool() {
			values[i] = roundValue(values[i], 0)
		} else if rng.NextBool() {
			values[i] = roundValue(values[i], 1)
		}
	}
	return values[0], values[1], values[2], values[3], values[4], values[5]
}

func main() {
	// Usage: go run example.go
	// Use the sequence 123 for this example
	rng := NewXorshift(123)
	for i := 1; i < 10; i++ {
		L1, a1, b1, L2, a2, b2 := getLabColors(rng)
		deltaE := ciede_2000(L1, a1, b1, L2, a2, b2)
		s_1, _ := json.Marshal(deltaE)
		s_2, _ := json.Marshal(L1)
		s_3, _ := json.Marshal(a1)
		s_4, _ := json.Marshal(b1)
		s_5, _ := json.Marshal(L2)
		s_6, _ := json.Marshal(a2)
		s_7, _ := json.Marshal(b2)
		fmt.Printf("%d. DeltaE2000=%s when L1=%s, a1=%s, b1=%s, L2=%s, a2=%s, b2=%s\n", i, string(s_1), string(s_2), string(s_3), string(s_4), string(s_5), string(s_6), string(s_7))
	}
}
