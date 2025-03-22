#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Compilation is done using GCC or CLang :
// - gcc -std=c99 -Wall -Wextra -pedantic -Ofast -o hokey-pokey hokey-pokey.c -lm
// - clang -std=c99 -Wall -Wextra -pedantic -Ofast -o hokey-pokey hokey-pokey.c -lm

// This function written in C99 is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Expressly defining constants ensures that the code works on different platforms.
#ifndef M_PI
#define M_PI 3.14159265358979323846264338328
#endif

#ifndef M_PI_2
#define M_PI_2 1.57079632679489661923132169164
#endif

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
static double ciede_2000(const double l_1, const double a_1, const double b_1, const double l_2, const double a_2, const double b_2) {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const double k_l = 1.0, k_c = 1.0, k_h = 1.0;
	double n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const double c_1 = hypot(a_1 * n, b_1), c_2 = hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	double h_1 = atan2(b_1, a_1 * n), h_2 = atan2(b_2, a_2 * n);
	h_1 += 2.0 * M_PI * (h_1 < 0.0);
	h_2 += 2.0 * M_PI * (h_2 < 0.0);
	n = fabs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (M_PI - 1E-14 < n && n < M_PI + 1E-14)
		n = M_PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	double h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
	if (M_PI < n) {
		if (0.0 < h_d)
			h_d -= M_PI;
		else
			h_d += M_PI;
		h_m += M_PI;
	}
	const double p = (36.0 * h_m - 55.0 * M_PI);
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const double r_t = -2.0 * sqrt(n / (n + 6103515625.0))
				* sin(M_PI / 3.0 * exp(p * p / (-25.0 * M_PI * M_PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const double l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const double t = 1.0 	+ 0.24 * sin(2.0 * h_m + M_PI_2)
				+ 0.32 * sin(3.0 * h_m + 8.0 * M_PI / 15.0)
				- 0.17 * sin(h_m + M_PI / 3.0)
				- 0.20 * sin(4.0 * h_m + 3.0 * M_PI_2 / 10.0);
	n = c_1 + c_2;
	// Hue.
	const double h = 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const double c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt(l * l + h * h + c * c + c * h * r_t);
}

struct test_row {
	double L1;
	double a1;
	double b1;
	double L2;
	double a2;
	double b2;
	double deltaE;
};

typedef unsigned long long int u64;

static struct test_row test_row = {0};
static char buf[255] = {0};

u64 xor_random(u64 *s) {
	// A shift-register generator has a reproducible behavior across platforms.
	return *s ^= *s << 13, *s ^= *s >> 7, *s ^= *s << 17 ;
}

static double rand_double_64(double min, double max, u64 * seed) {
	// Generate a 64-bit random integer by combining 8 random bytes
	// Normalize to the range [0, 1) and scale to [min, max)
	return min + (max - min) * ((double) xor_random(seed) / 18446744073709551616.0);
}

static void prepare_values(int num) {
	u64 seed = 0x2236b69a7d223bd ^ (u64)num ^ (u64)&errno ;
	*buf = 0;
	sprintf(buf, "./values-c.txt");
	printf("prepare_values('%s', %d)\n", buf, num);
	FILE *fp = fopen(buf, "w");
	for (int i = 0; i < num; ++i) {
		struct test_row r = {
				rand_double_64(0, 100, &seed),
				rand_double_64(-128, 128, &seed),
				rand_double_64(-128, 128, &seed),
				rand_double_64(0, 100, &seed),
				rand_double_64(-128, 128, &seed),
				rand_double_64(-128, 128, &seed),
				0.
		};
		const u64 type = xor_random(&seed);
		if (type & 1) r.L1 = round(r.L1);
		if (type & 2) r.a1 = round(r.a1);
		if (type & 4) r.b1 = round(r.b1);
		if (type & 8) r.L2 = round(r.L2);
		if (type & 16) r.a2 = round(r.a2);
		if (type & 32) r.b2 = round(r.b2);
		r.deltaE = ciede_2000(r.L1, r.a1, r.b1, r.L2, r.a2, r.b2);
		fprintf(fp, "%.17g,%.17g,%.17g,%.17g,%.17g,%.17g,%.17g\n", r.L1, r.a1, r.b1, r.L2, r.a2, r.b2, r.deltaE);
		if (i % 1000 == 0) {
			putchar('.');
			fflush(stdout);
		}
	}
	fclose(fp);
}

static void compare_values(const char *ext) {
	*buf = 0;
	sprintf(buf, "./../%s/values-%s.txt", ext, ext);
	printf("compare_values('%s')\n", buf);
	FILE *fp = fopen(buf, "r");
	int n_rows = 0, n_err = 0;
	struct test_row *r = &test_row;
	while (fgets(buf, 1023, fp)) {
		++n_rows;
		buf[strlen(buf) - 1] = 0;
		char *s = strtok(buf, ",");
		int j = -1;
		while (s) {
			++j;
			if (j == 0) r->L1 = atof(s);
			else if (j == 1) r->a1 = atof(s);
			else if (j == 2) r->b1 = atof(s);
			else if (j == 3) r->L2 = atof(s);
			else if (j == 4) r->a2 = atof(s);
			else if (j == 5) r->b2 = atof(s);
			else if (j == 6) r->deltaE = atof(s);
			s = strtok(NULL, ",");
		}
		const double calc = ciede_2000(r->L1, r->a1, r->b1, r->L2, r->a2, r->b2);
		const double err = fabs(calc - r->deltaE);
		if ((calc != calc) || (1e-10 < err)) {
			printf("%d. read [%g,%g,%g] [%g,%g,%g] expect %g get %g (err=%g)\n", ++n_err, r->L1, r->a1, r->b1, r->L2,
				   r->a2, r->b2,
				   r->deltaE, calc, err);
			break;
		} else if (n_rows % 1000 == 0) {
			putchar('.');
			fflush(stdout);
		}
	}
	fclose(fp);
}

static int is_alpha(char *s) {
	for (; *s; ++s)
		if ((*s < 'a' || 'z' < *s) && (*s < 'A' || 'Z' < *s))
			return 0;
	return 1;
}

int main(int argc, char *argv[]) {
	char **end = NULL;
	if (argc && is_alpha(argv[1]))
		compare_values(argv[1]);
	else
		prepare_values(argc ? strtol(argv[1], end, 10) : 10000);
}
