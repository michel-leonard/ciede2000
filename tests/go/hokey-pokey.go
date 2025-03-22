package main

import (
	"bufio"
	"math"
	"math/rand"
	"fmt"
	"os"
	"strconv"
	"strings"
	"regexp"
	"time"
)

// This function written in Go is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
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

func random_float(min float64, max float64) float64 {
	val := min + rand.Float64() * (max - min)
	if rand.Intn(2) == 0 {
		return val
	} else if rand.Intn(2) == 0 {
		return math.Round(val)
	} else {
		return math.Round(val * 10) * 0.1
	}
}

func prepare_values(n int) {
	const path = "./values-go.txt"
	fmt.Printf("prepare_values('%s', %d)\n", path, n)
	file, err := os.Create(path)
	if err != nil {
		fmt.Println("Error creating file:", err)
		return
	}
	defer file.Close()
	rand.Seed(time.Now().UnixNano())
	for i := 1; i <= n; i++ {
		l1 := random_float(0, 128)
		a1 := random_float(-128, 128)
		b1 := random_float(-128, 128)
		l2 := random_float(0, 128)
		a2 := random_float(-128, 128)
		b2 := random_float(-128, 128)
		deltaE := ciede_2000(l1, a1, b1, l2, a2, b2)
		line := fmt.Sprintf("%.17f,%.17f,%.17f,%.17f,%.17f,%.17f,%.17f\n", l1, a1, b1, l2, a2, b2, deltaE)
		file.WriteString(line)
		if i % 1000 == 0 {
			fmt.Print(".")
		}
	}
}

func compare_values(extension string) {
	path := fmt.Sprintf("./../%s/values-%s.txt", extension, extension)
	fmt.Printf("compare_values('%s')\n", path)
	file, err := os.Open(path)
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()
	scanner := bufio.NewScanner(file)
	n_errors := 0
	n_lines := 0
	for scanner.Scan() {
		n_lines++
		fields := strings.Split(scanner.Text(), ",")
		if len(fields) != 7 {
			fmt.Println("Invalid line format at line", n_lines)
			continue
		}
		values := make([]float64, 7)
		for i, field := range fields {
			val, err := strconv.ParseFloat(strings.TrimSpace(field), 64)
			if err != nil {
				fmt.Println("Error parsing number at line", n_lines, ":", err)
				return
			}
			values[i] = val
		}
		delta_e := ciede_2000(values[0], values[1], values[2], values[3], values[4], values[5])

		if math.IsNaN(delta_e) || math.Abs(delta_e - values[6]) > 1e-10 {
			fmt.Printf("Error at line %d: expected %.12f, got %.12f\n", n_lines, values[6], delta_e)
			n_errors++
			if n_errors >= 10 {
				fmt.Println("Too many errors, stopping.")
				return
			}
		}
		if n_lines%1000 == 0 {
			fmt.Print(".")
		}
	}
}

var is_digit = regexp.MustCompile(`^[1-9][0-9]{0,7}$`).MatchString
var is_alpha = regexp.MustCompile(`^[a-zA-Z]+$`).MatchString

func main(){
	if len(os.Args) == 2 {
		input := os.Args[1]
		if is_digit(input) {
			n, _ := strconv.Atoi(input)
			prepare_values(n)
			return
		} else if is_alpha(input) {
			compare_values(strings.ToLower(input))
			return
		}	
	}
	fmt.Println("Usage:")
	fmt.Println("  - Provide a positive integer between 1 and 10,000,000 to produce a test file.")
	fmt.Println("  - Provide an extension to compare the results of the ciede_2000 function.")
	fmt.Println("  - Any other input will show this help message.")
}
