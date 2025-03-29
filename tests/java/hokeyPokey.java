// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// javac hokeyPokey.java

import static java.lang.Math.PI;
import static java.lang.Math.sqrt;
import static java.lang.Math.hypot;
import static java.lang.Math.atan2;
import static java.lang.Math.abs;
import static java.lang.Math.sin;
import static java.lang.Math.exp;

import java.io.*;
import java.util.Random;
import java.util.Scanner;

public class hokeyPokey {

	// This function written in Java is not affiliated with the CIE (International Commission on Illumination),
	// and is released into the public domain. It is provided "as is" without any warranty, express or implied.
	
	// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
	static double ciede_2000(final double l_1, final double a_1, final double b_1, final double l_2, final double a_2, final double b_2) {
		// Working with the CIEDE2000 color-difference formula.
		// k_l, k_c, k_h are parametric factors to be adjusted according to
		// different viewing parameters such as textures, backgrounds...
		final double k_l = 1.0, k_c = 1.0, k_h = 1.0;
		double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
		n = n * n * n * n * n * n * n;
		// A factor involving chroma raised to the power of 7 designed to make
		// the influence of chroma on the total color difference more accurate.
		n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
		// hypot calculates the Euclidean distance while avoiding overflow/underflow.
		final double c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
		// atan2 is preferred over atan because it accurately computes the angle of
		// a point (x, y) in all quadrants, handling the signs of both coordinates.
		double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
		h_1 += 2.0 * PI * Boolean.compare(h_1 < 0.0, false);
		h_2 += 2.0 * PI * Boolean.compare(h_2 < 0.0, false);
		n = abs(h_2 - h_1);
		// Cross-implementation consistent rounding.
		if (PI - 1E-14 < n && n < PI + 1E-14)
			n = PI;
		// When the hue angles lie in different quadrants, the straightforward
		// average can produce a mean that incorrectly suggests a hue angle in
		// the wrong quadrant, the next lines handle this issue.
		double h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
		if (PI < n) {
			if (0.0 < h_d)
				h_d -= PI;
			else
				h_d += PI;
			h_m += PI;
		}
		final double p = (36.0 * h_m - 55.0 * PI);
		n = (c_1 + c_2) * 0.5;
		n = n * n * n * n * n * n * n;
		// The hue rotation correction term is designed to account for the
		// non-linear behavior of hue differences in the blue region.
		final double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(PI / 3.0 * exp(p * p / (-25.0 * PI * PI)));
		n = (l_1 + l_2) * 0.5;
		n = (n - 50.0) * (n - 50.0);
		// Lightness.
		final double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
		// These coefficients adjust the impact of different harmonic
		// components on the hue difference calculation.
		final double t = 1.0 + 0.24 * sin(2.0 * h_m + PI / 2.0)
				+ 0.32 * sin(3.0 * h_m + 8.0 * PI / 15.0)
				- 0.17 * sin(h_m + PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * PI / 20.0);
		n = c_1 + c_2;
		// Hue.
		final double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
		// Chroma.
		final double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
		// Returning the square root ensures that the result represents
		// the "true" geometric distance in the color space.
		return sqrt(l * l + h * h + c * c + c * h * r_t);
	}
	
	// GitHub Project : https://github.com/michel-leonard/ciede2000
	//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html
	
	// L1 = 57.8           a1 = 95.5           b1 = 14.5757
	// L2 = 57.8           a2 = 95.5           b2 = 14.556
	// CIE ΔE2000 = ΔE00 = 0.0072619914
	
	// L1 = 23.55          a1 = 1.946          b1 = 5.0
	// L2 = 23.55          a2 = 1.946          b2 = 5.66
	// CIE ΔE2000 = ΔE00 = 0.54480792606
	
	// L1 = 37.1           a1 = -70.863        b1 = 110.0
	// L2 = 37.1           a2 = -70.783        b2 = 105.23
	// CIE ΔE2000 = ΔE00 = 0.98794101092
	
	// L1 = 67.6           a1 = -40.3          b1 = -68.0
	// L2 = 67.6           a2 = -50.1          b2 = -68.0
	// CIE ΔE2000 = ΔE00 = 3.12607209418
	
	// L1 = 54.48          a1 = -14.0          b1 = 95.86
	// L2 = 54.48          a2 = -6.0           b2 = 95.86
	// CIE ΔE2000 = ΔE00 = 4.04255464332
	
	// L1 = 5.47           a1 = 16.853         b1 = -50.47
	// L2 = 7.8011         a2 = 4.0            b2 = -39.3
	// CIE ΔE2000 = ΔE00 = 5.12374182234
	
	// L1 = 96.92          a1 = 3.0            b1 = -103.0
	// L2 = 84.606         a2 = 8.93           b2 = -93.0
	// CIE ΔE2000 = ΔE00 = 9.17123410038
	
	// L1 = 12.2285        a1 = 109.291        b1 = 61.3
	// L2 = 12.2           a2 = 66.295         b2 = 28.153
	// CIE ΔE2000 = ΔE00 = 10.81362667601
	
	// L1 = 33.94          a1 = -5.92          b1 = 22.7742
	// L2 = 71.7           a2 = -58.0          b2 = 3.7
	// CIE ΔE2000 = ΔE00 = 45.4772324751
	
	// L1 = 79.0           a1 = 103.0          b1 = -28.06
	// L2 = 71.515         a2 = -76.7          b2 = -44.46
	// CIE ΔE2000 = ΔE00 = 99.64098709948

	public static void prepare_values(int numLines) {
		String filename = "./values-java.txt";
		System.out.printf("prepare_values('%s', %d)\n", filename, numLines);
		try (PrintWriter writer = new PrintWriter(new FileWriter(filename))) {
			Random rand = new Random();
			for (int i = 0; i < numLines; i++) {
				double L1 = 100.0 * rand.nextDouble();
				double a1 = -128.0 + 256.0 * rand.nextDouble();
				double b1 = -128.0 + 256.0 * rand.nextDouble();
				double L2 = 100.0 * rand.nextDouble();
				double a2 = -128.0 + 256.0 * rand.nextDouble();
				double b2 = -128.0 + 256.0 * rand.nextDouble();

				if (i % 2 == 1) { // Round to nearest integer on odd counts
					L1 = Math.round(L1);
					a1 = Math.round(a1);
					b1 = Math.round(b1);
					L2 = Math.round(L2);
					a2 = Math.round(a2);
					b2 = Math.round(b2);
				} else if (i % 1000 == 0) {
					System.out.print('.');
					System.out.flush();
				}
				
				double deltaE = ciede_2000(L1, a1, b1, L2, a2, b2);
				writer.print(L1);
				writer.print(',');
				writer.print(a1);
				writer.print(',');
				writer.print(b1);
				writer.print(',');
				writer.print(L2);
				writer.print(',');
				writer.print(a2);
				writer.print(',');
				writer.print(b2);
				writer.print(',');
				writer.print(deltaE);
				writer.print('\n');
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void compare_values(String ext) {
		String filename = "./../" + ext + "/values-" + ext + ".txt";
		System.out.printf("compare_values('%s')\n", filename);
		try (Scanner scanner = new Scanner(new File(filename))) {
			int i = 0;
			while (scanner.hasNextLine()) {
				i++;
				String[] line = scanner.nextLine().split(",");
				double L1 = Double.parseDouble(line[0]);
				double a1 = Double.parseDouble(line[1]);
				double b1 = Double.parseDouble(line[2]);
				double L2 = Double.parseDouble(line[3]);
				double a2 = Double.parseDouble(line[4]);
				double b2 = Double.parseDouble(line[5]);
				double delta_e = Double.parseDouble(line[6]);

				double res = ciede_2000(L1, a1, b1, L2, a2, b2);
				if (!Double.isFinite(res) || !Double.isFinite(delta_e) || Math.abs(res - delta_e) > 1e-10) {
					System.out.println("Error on line " + i + ": expected " + delta_e + ", got " + res);
				} else if (i % 1000 == 0) {
					System.out.print('.');
					System.out.flush();
				}
			}
		} catch (FileNotFoundException e) {
			System.out.println("File " + filename + " not found.");
		}
	}

	public static void main(String[] args) {
		if (args[0].matches("^[1-9][0-9]{0,7}$"))
			prepare_values(Integer.parseInt(args[0]));
		else if (args[0].matches("^[a-z]+$"))
			compare_values(args[0]);
		else
			prepare_values(10000);
	}
}
