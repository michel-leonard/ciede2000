use std::f64::consts::PI;
use std::fs::File;
use std::io::{Write, BufWriter, BufRead};
use std::env;
use std::f64;
use rand::Rng;

// This function written in Rust is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
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
	let mut h_m = 0.5 * h_1 + 0.5 * h_2;
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

fn prepare_values(n_nums: usize) {
	let file = File::create("values-rs.txt").expect("Can't write to the file");
	println!("prepare_values('./values-rs.txt', {})", n_nums);
	let mut writer = BufWriter::new(file);
	let mut rng = rand::thread_rng();
	
	for i in 0..n_nums {
		let l1 = rng.gen_range(0.0..=100.0);
		let a1 = rng.gen_range(-128.0..=128.0);
		let b1 = rng.gen_range(-128.0..=128.0);
		let l2 = rng.gen_range(0.0..=100.0);
		let a2 = rng.gen_range(-128.0..=128.0);
		let b2 = rng.gen_range(-128.0..=128.0);

		let mut values = [l1, a1, b1, l2, a2, b2];
		for v in &mut values {
			if rng.gen_range(0.0..=1.0) < 0.5 {
				let n = *v as u32;
				*v = n as f64;
			}
		}

		let delta_e = ciede_2000(values[0], values[1], values[2], values[3], values[4], values[5]);
		writeln!(writer, "{},{},{},{},{},{},{}", values[0], values[1], values[2], values[3], values[4], values[5], delta_e)
			.expect("Error or write");

		if (i + 1) % 1000 == 0 {
			print!(".");
			std::io::stdout().flush().unwrap();
		}
	}
}

fn compare_values(name: &str) {
	let path = format!("./../{}/values-{}.txt", name, name);
	println!("compare_values('{}')", path);

	let file = File::open(&path).expect("Can't read the file");
	let reader = std::io::BufReader::new(file);

	let mut error_count = 0;
	for (i, line) in reader.lines().enumerate() {
		let line = line.expect("Can't read the line");
		let values: Vec<f64> = line.split(',')
			.map(|v| v.parse::<f64>().expect("Can't type cast the line"))
			.collect();

		if values.len() != 7 {
			eprintln!("Incorrect format at line {}", i + 1);
			continue;
		}

		let computed = ciede_2000(values[0], values[1], values[2], values[3], values[4], values[5]);
		if !computed.is_finite() || (computed - values[6]).abs() > 1e-10 {
			eprintln!("Error ar line {}: expected {}, got {}", i + 1, values[6], computed);
			error_count += 1;
			if error_count >= 10 {
				break;
			}
		}

		if (i + 1) % 1000 == 0 {
			print!(".");
			std::io::stdout().flush().unwrap();
		}
	}
}

fn main() {
	let args: Vec<String> = env::args().collect();
	if args.len() != 2 {
		eprintln!("Usage: {} <positive number | string>", args[0]);
		return;
	}

	let arg = &args[1];
	if let Ok(n) = arg.parse::<usize>() {
		prepare_values(n)
	} else if arg.chars().all(char::is_alphabetic) {
		compare_values(&arg.to_lowercase());
	} else {
		eprintln!("Error: try 10000 to generate a file, or 'php' to test a file");
	}
}
