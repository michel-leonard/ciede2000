// These color conversion functions written in C are released into the public domain.
// They are provided "as is" without any warranty, express or implied.

#include <math.h>

// rgb in 0..1
static void rgb_to_xyz(double r, double g, double b, double *x, double *y, double *z) {

	// Apply a gamma correction to each channel
	r = r > 0.0404482362771082 ? pow((r + 0.055) / 1.055, 2.4) : r / 12.92;
	g = g > 0.0404482362771082 ? pow((g + 0.055) / 1.055, 2.4) : g / 12.92;
	b = b > 0.0404482362771082 ? pow((b + 0.055) / 1.055, 2.4) : b / 12.92;

	// Convert to XYZ using the sRGB color space
	*x = 100.0 * (r * 0.4124564390896921 + g * 0.357576077643909 + b * 0.18043748326639894);
	*y = 100.0 * (r * 0.21267285140562248 + g * 0.715152155287818 + b * 0.07217499330655958);
	*z = 100.0 * (r * 0.019333895582329317 + g * 0.119192025881303 + b * 0.9503040785363677);

}

static void xyz_to_lab(double x, double y, double z, double *l, double *a, double *b) {
	// Reference white point (D65)
	const double refX = 95.047;
	const double refY = 100.0;
	const double refZ = 108.883;

	x /= refX;
	y /= refY;
	z /= refZ;

	// Applying the CIE standard transformation
	x = x > 216.0 / 24389.0 ? cbrt(x) : ((841.0 / 108.0) * x) + (4.0 / 29.0);
	y = y > 216.0 / 24389.0 ? cbrt(y) : ((841.0 / 108.0) * y) + (4.0 / 29.0);
	z = z > 216.0 / 24389.0 ? cbrt(z) : ((841.0 / 108.0) * z) + (4.0 / 29.0);

	*l = (116.0 * y) - 16.0;
	*a = 500.0 * (x - y);
	*b = 200.0 * (y - z);
}

// rgb (0..1)
static void rgb_to_lab(double r, double g, double b, double *l, double *a, double *bb) {
	rgb_to_xyz(r, g, b, l, a, bb);
	xyz_to_lab(*l, *a, *bb, l, a, bb);
}

static void lab_to_xyz(double l, double a, double b, double *x, double *y, double *z) {
	// Reference white point (D65)
	const double refX = 95.047;
	const double refY = 100.000;
	const double refZ = 108.883;

	*y = (l + 16.0) / 116.0;
	*x = a / 500.0 + *y;
	*z = *y - b / 200.0;

	const double x3 = *x * *x * *x;
	const double y3 = *y * *y * *y;
	const double z3 = *z * *z * *z;

	*x = refX * (x3 > 216.0 / 24389.0 ? x3 : (*x - 4.0 / 29.0) / (841.0 / 108.0));
	*y = refY * (l > 8.0 ? y3 : l / (24389.0 / 27.0));
	*z = refZ * (z3 > 216.0 / 24389.0 ? z3 : (*z - 4.0 / 29.0) / (841.0 / 108.0));
}

// rgb in 0..1
void xyz_to_rgb(double x, double y, double z, double *r, double *g, double *b) {
	// Normalize for the sRGB color space
	x /= 100.0;
	y /= 100.0;
	z /= 100.0;

	// # The constants are based on the sRGB color primaries in "xy" and D65 whitepoint in "XYZ"
	*r = x * 3.2404541621141054 + y * -1.5371385127977166 + z * -0.4985314095560162;
	*g = x * -0.9692660305051868 + y * 1.8760108454466942 + z * 0.04155601753034984;
	*b = x * 0.05564343095911469 + y * -0.20402591351675387 + z * 1.0572251882231791;

	// Apply gamma correction
	*r = *r > 0.0031306684425005883 ? 1.055 * pow(*r, 1.0 / 2.4) - 0.055 : 12.92 * *r;
	*g = *g > 0.0031306684425005883 ? 1.055 * pow(*g, 1.0 / 2.4) - 0.055 : 12.92 * *g;
	*b = *b > 0.0031306684425005883 ? 1.055 * pow(*b, 1.0 / 2.4) - 0.055 : 12.92 * *b;

}

// rgb from 0..1 to 0..255
static void float_to_rgb(double r, double g, double b, int *R, int *G, int *B) {
	// Convert to 0-255 range and clamp
	*R = (int) floor(0.5 + (r < 0.0 ? 0.0 : 255.0 < r ? 255.0 : r * 255.0));
	*G = (int) floor(0.5 + (g < 0.0 ? 0.0 : 255.0 < g ? 255.0 : g * 255.0));
	*B = (int) floor(0.5 + (b < 0.0 ? 0.0 : 255.0 < b ? 255.0 : b * 255.0));
}

// rgb from 0..255 to 0..1
static void rgb_to_float(int r, int g, int b, double *R, double *G, double *B) {
	// Normalize RGB values to the range 0 to 1
	*R = r / 255.0;
	*G = g / 255.0;
	*B = b / 255.0;
}

// rgb in 0..1
static void lab_to_rgb(double l, double a, double b, double *_r, double *_g, double *_b) {
	lab_to_xyz(l, a, b, &l, &a, &b);
	xyz_to_rgb(l, a, b, _r, _g, _b);
}

//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
///////////////                                ///////////////////////
///////////////                                ///////////////////////
///////////////         --  TESTING --         ///////////////////////
///////////////                                ///////////////////////
///////////////                                ///////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////

#include <stdio.h>

unsigned long long int xor_random(unsigned long long int *s) {
	// A shift-register generator has a reproducible behavior across platforms.
	return *s ^= *s << 13, *s ^= *s >> 7, *s ^= *s << 17;
}

static double rand_double_64(double min, double max, unsigned long long int *seed) {
	// Generate a 64-bit random integer by combining 8 random bytes
	// Normalize to the range [0, 1) and scale to [min, max)
	return min + (max - min) * ((double) xor_random(seed) / 18446744073709551616.0);
}


void test_lab_and_xyz(unsigned long long int *seed, int count, double tolerance) {
	double err_l = 0.0, err_a = 0.0, err_b = 0.0;
	for (int i = 0; i < count; ++i) {
		const double L = rand_double_64(0.0, 100.0, seed);
		const double A = rand_double_64(-128.0, 128.0, seed);
		const double B = rand_double_64(-128.0, 128.0, seed);
		double x, y, z, l, a, b;
		lab_to_xyz(L, A, B, &x, &y, &z);
		xyz_to_lab(x, y, z, &l, &a, &b);
		if (err_l < fabs(L - l))
			err_l = fabs(L - l);
		if (err_a < fabs(A - a))
			err_a = fabs(A - a);
		if (err_b < fabs(B - b))
			err_b = fabs(B - b);
	}
	if (err_l < tolerance && err_a < tolerance && err_b < tolerance)
		printf("lab_to_xyz <=> xyz_to_lab : PASS\n");
	else
		printf("lab_to_xyz <=> xyz_to_lab : err_l=%g, err_a=%g, err_b=%g\n", err_l, err_a, err_b);
}

void test_xyz_and_lab(unsigned long long int *seed, int count, double tolerance) {
	double err_x = 0.0, err_y = 0.0, err_z = 0.0;
	for (int i = 0; i < count; ++i) {
		// Illuminant = D65
		const double X = rand_double_64(0.0, 95.047, seed);
		const double Y = rand_double_64(0.0, 100.0, seed);
		const double Z = rand_double_64(0.0, 108.883, seed);
		double l, a, b, x, y, z;
		xyz_to_lab(X, Y, Z, &l, &a, &b);
		lab_to_xyz(l, a, b, &x, &y, &z);
		if (err_x < fabs(X - x))
			err_x = fabs(X - x);
		if (err_y < fabs(Y - y))
			err_y = fabs(Y - y);
		if (err_z < fabs(Z - z))
			err_z = fabs(Z - z);
	}
	if (err_x < tolerance && err_y < tolerance && err_z < tolerance)
		printf("xyz_to_lab <=> lab_to_xyz : PASS\n");
	else
		printf("xyz_to_lab <=> lab_to_xyz : err_x=%g, err_y=%g, err_z=%g\n", err_x, err_y, err_z);
}

void test_lab_and_rgb(unsigned long long int *seed, int count, double tolerance) {
	double err_l = 0.0, err_a = 0.0, err_b = 0.0;
	for (int i = 0; i < count; ++i) {
		const double L = rand_double_64(0.0, 100.0, seed);
		const double A = rand_double_64(-128.0, 128.0, seed);
		const double B = rand_double_64(-128.0, 128.0, seed);
		double x, y, z, l, a, b;
		lab_to_rgb(L, A, B, &x, &y, &z);
		rgb_to_lab(x, y, z, &l, &a, &b);
		if (err_l < fabs(L - l))
			err_l = fabs(L - l);
		if (err_a < fabs(A - a))
			err_a = fabs(A - a);
		if (err_b < fabs(B - b))
			err_b = fabs(B - b);
	}
	if (err_l < tolerance && err_a < tolerance && err_b < tolerance)
		printf("lab_to_xyz <=> xyz_to_lab : PASS\n");
	else
		printf("lab_to_xyz <=> xyz_to_lab : err_l=%g, err_a=%g, err_b=%g\n", err_l, err_a, err_b);
}

void test_rgb_and_lab(unsigned long long int *seed, int count, double tolerance) {
	double err_r = 0.0, err_g = 0.0, err_b = 0.0;
	for (int i = 0; i < count; ++i) {
		const double R = rand_double_64(0.0, 1.0, seed);
		const double G = rand_double_64(0.0, 1.0, seed);
		const double B = rand_double_64(0.0, 1.0, seed);
		double l, a, b, r, g, bb;
		rgb_to_lab(R, G, B, &l, &a, &b);
		lab_to_rgb(l, a, b, &r, &g, &bb);
		if (err_r < fabs(R - r))
			err_r = fabs(R - r);
		if (err_g < fabs(G - g))
			err_g = fabs(G - g);
		if (err_b < fabs(B - bb))
			err_b = fabs(B - bb);
	}
	if (err_r < tolerance && err_g < tolerance && err_b < tolerance)
		printf("rgb_to_lab <=> lab_to_rgb : PASS\n");
	else
		printf("rgb_to_lab <=> lab_to_rgb : err_r=%g, err_g=%g, err_b=%g\n", err_r, err_g, err_b);
}

void test_rgb_and_xyz(unsigned long long int *seed, int count, double tolerance) {
	double err_r = 0.0, err_g = 0.0, err_b = 0.0;
	for (int i = 0; i < count; ++i) {
		const double R = rand_double_64(0.0, 1.0, seed);
		const double G = rand_double_64(0.0, 1.0, seed);
		const double B = rand_double_64(0.0, 1.0, seed);
		double x, y, z, r, g, b;
		rgb_to_xyz(R, G, B, &x, &y, &z);
		xyz_to_rgb(x, y, z, &r, &g, &b);
		if (err_r < fabs(R - r))
			err_r = fabs(R - r);
		if (err_g < fabs(G - g))
			err_g = fabs(G - g);
		if (err_b < fabs(B - b))
			err_b = fabs(B - b);
	}
	if (err_r < tolerance && err_g < tolerance && err_b < tolerance)
		printf("rgb_to_xyz <=> xyz_to_rgb : PASS\n");
	else
		printf("rgb_to_xyz <=> xyz_to_rgb : err_r=%g, err_g=%g, err_b=%g\n", err_r, err_g, err_b);
}

void test_xyz_and_rgb(unsigned long long int *seed, int count, double tolerance) {
	double err_x = 0.0, err_y = 0.0, err_z = 0.0;
	for (int i = 0; i < count; ++i) {
		// Illuminant = D65
		const double X = rand_double_64(0.0, 95.047, seed);
		const double Y = rand_double_64(0.0, 100.0, seed);
		const double Z = rand_double_64(0.0, 108.883, seed);
		double r, g, b, x, y, z;
		xyz_to_rgb(X, Y, Z, &r, &g, &b);
		rgb_to_xyz(r, g, b, &x, &y, &z);
		if (err_x < fabs(X - x))
			err_x = fabs(X - x);
		if (err_y < fabs(Y - y))
			err_y = fabs(Y - y);
		if (err_z < fabs(Z - z))
			err_z = fabs(Z - z);
	}
	if (err_x < tolerance && err_y < tolerance && err_z < tolerance)
		printf("xyz_to_rgb <=> rgb_to_xyz : PASS\n");
	else
		printf("xyz_to_rgb <=> rgb_to_xyz : err_x=%g, err_y=%g, err_z=%g\n", err_x, err_y, err_z);
}

#include <stdlib.h> // The "abs" function requires this header.

void test_rgb_and_rgb_float(unsigned long long int *seed, int count) {
	int err_r = 0, err_g = 0, err_b = 0;
	for (int i = 0; i < count; ++i) {
		const int R = (int) floor(0.5 + rand_double_64(0.0, 255.0, seed));
		const int G = (int) floor(0.5 + rand_double_64(0.0, 255.0, seed));
		const int B = (int) floor(0.5 + rand_double_64(0.0, 255.0, seed));
		double r_float, g_float, b_float;
		int r, g, b;
		rgb_to_float(R, G, B, &r_float, &g_float, &b_float);
		float_to_rgb(r_float, g_float, b_float, &r, &g, &b);
		if (err_r < abs(R - r))
			err_r = abs(R - r);
		if (err_g < abs(G - g))
			err_g = abs(G - g);
		if (err_b < abs(B - b))
			err_b = abs(B - b);
	}
	if (err_r == 0 && err_g == 0 && err_b == 0)
		printf("rgb_to_float <=> float_to_rgb : PASS\n");
	else
		printf("rgb_to_float <=> float_to_rgb : err_r=%d, err_g=%d, err_b=%d\n", err_r, err_g, err_b);
}

int main(void) {
	const int count = 10000000, id = 1; // Select the number of iterations and the ID of the tested sequence.
	double tolerance = 0.00000000001 ; // Define the tolerance (epsilon) in floating point exact comparisons.
	unsigned long long int _seed = 0x2236b69a7d223bd ^ id, seed; // Create the random seed based on the ID.
	printf("Color Conversion Test: %d iterations of the sequence No. %d.\n", count, id);
	seed = _seed, test_lab_and_xyz(&seed, count, tolerance); // perform lab -> xyz -> lab and print the errors.
	seed = _seed, test_xyz_and_lab(&seed, count, tolerance); // perform xyz -> lab -> xyz and print the errors.
	seed = _seed, test_lab_and_rgb(&seed, count, tolerance); // perform lab -> rgb -> lab and print the errors.
	seed = _seed, test_rgb_and_lab(&seed, count, tolerance); // perform rgb -> lab -> rgb and print the errors.
	seed = _seed, test_rgb_and_xyz(&seed, count, tolerance); // perform rgb -> xyz -> rgb and print the errors.
	seed = _seed, test_xyz_and_rgb(&seed, count, tolerance); // perform xyz -> rgb -> xyz and print the errors.
	seed = _seed, test_rgb_and_rgb_float(&seed, count); // perform rgb (0..255) -> rgb (0..1) -> rgb (0..255) and print the errors.
}

// Compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o rgb-xyz-lab-tests rgb-xyz-lab.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o rgb-xyz-lab-tests rgb-xyz-lab.c -lm

// Constants used in Color Conversion :
// 216.0 / 24389.0 = 0.0088564516790356308171716757554635286399606379925376194185903481077
// 841.0 / 108.0 = 7.78703703703703703703703703703703703703703703703703703703703703703703703703
// 4.0 / 29.0 = 0.13793103448275862068965517241379310344827586206896551724137931034482758620
// 24389.0 / 27.0 = 903.296296296296296296296296296296296296296296296296296296296296296296296296
// 1.0 / 2.4 = 0.41666666666666666666666666666666666666666666666666666666666666666666666666
