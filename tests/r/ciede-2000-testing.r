# This function written in R is not affiliated with the CIE (International Commission on Illumination),
# and is released into the public domain. It is provided "as is" without any warranty, express or implied.

ciede_2000_classic <- function(l_1, a_1, b_1, l_2, a_2, b_2) {
	# This scalar expansion wrapper works with numbers, not vectors.
	delta_e <- ciede_2000(c(l_1), c(a_1), c(b_1), c(l_2), c(a_2), c(b_2))
	return(delta_e[1])
}

# The classic vectorized CIE ΔE implementation, ΔE2000 (ΔE00).
ciede_2000 <- function(l_1, a_1, b_1, l_2, a_2, b_2) {
	# Working with R and the CIEDE2000 color-difference formula.
	# k_l, k_c, k_h are parametric factors to be adjusted according to
	# different viewing parameters such as textures, backgrounds...
	k_l <- 1.0;
	k_c <- 1.0;
	k_h <- 1.0;
	n <- (sqrt(a_1 * a_1 + b_1 * b_1) + sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n <- n * n * n * n * n * n * n;
	# A factor involving chroma raised to the power of 7 designed to make
	# the influence of chroma on the total color difference more accurate.
	n <- 1.0 + 0.5 * (1.0 - sqrt(n / (n + 6103515625.0)));
	# Since hypot is not available, sqrt is used here to calculate the
	# Euclidean distance, without avoiding overflow/underflow.
	c_1 <- sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	c_2 <- sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	# atan2 is preferred over atan because it accurately computes the angle of
	# a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 <- atan2(b_1, a_1 * n);
	h_2 <- atan2(b_2, a_2 * n);
	h_1[h_1 < 0] <- h_1[h_1 < 0] + 2.0 * pi;
	h_2[h_2 < 0] <- h_2[h_2 < 0] + 2.0 * pi;
	n <- abs(h_2 - h_1);
	# Cross-implementation consistent rounding.
	n[abs(n - pi) < 1E-14] <- pi;
	# When the hue angles lie in different quadrants, the straightforward
	# average can produce a mean that incorrectly suggests a hue angle in
	# the wrong quadrant, the next lines handle this issue.
	h_m <- (h_1 + h_2) * 0.5;
	h_d <- (h_2 - h_1) * 0.5;
	m_1 <- (pi < n);
	m_2 <- (0.0 < h_d);
	h_d[m_1 & m_2] <- h_d[m_1 & m_2] - pi;
	h_d[m_1 & !m_2] <- h_d[m_1 & !m_2] + pi;
	h_m[m_1] <- h_m[m_1] + pi;
	p <- 36.0 * h_m - 55.0 * pi;
	n <- (c_1 + c_2) * 0.5;
	n <- n * n * n * n * n * n * n;
	# The hue rotation correction term is designed to account for the
	# non-linear behavior of hue differences in the blue region.
	r_t <- -2.0 * sqrt(n / (n + 6103515625.0)) *
					sin(pi / 3.0 * exp(p * p / (-25.0 * pi * pi)));
	n <- (l_1 + l_2) * 0.5;
	n <- (n - 50.0) * (n - 50.0);
	# Lightness.
	l <- (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / sqrt(20.0 + n)));
	# These coefficients adjust the impact of different harmonic
	# components on the hue difference calculation.
	t <- 1.0 +	0.24 * sin(2.0 * h_m + pi * 0.5) +
				0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0) -
				0.17 * sin(h_m + pi / 3.0) -
				0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
	n <- c_1 + c_2;
	# Hue.
	h <- 2.0 * sqrt(c_1 * c_2) * sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	# Chroma.
	c <- (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	# Returning the square root ensures that the result represents
	# the "true" geometric distance in the color space.
	return(sqrt(l * l + h * h + c * c + c * h * r_t));
}

# GitHub Project : https://github.com/michel-leonard/ciede2000
#  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

# L1 = 37.4556        a1 = -2.684         b1 = 23.405
# L2 = 37.4556        a2 = -2.7           b2 = 23.405
# CIE ΔE2000 = ΔE00 = 0.01513790371

# L1 = 48.2           a1 = 99.0           b1 = 127.7
# L2 = 48.8           a2 = 98.0           b2 = 126.5217
# CIE ΔE2000 = ΔE00 = 0.62511309239

# L1 = 38.333         a1 = 70.529         b1 = -60.1
# L2 = 38.333         a2 = 63.23          b2 = -53.8485
# CIE ΔE2000 = ΔE00 = 1.94057413285

# L1 = 73.8           a1 = 83.564         b1 = -15.3
# L2 = 73.8           a2 = 83.564         b2 = -24.33
# CIE ΔE2000 = ΔE00 = 3.09812706782

# L1 = 15.775         a1 = 55.791         b1 = 8.0
# L2 = 22.2           a2 = 55.791         b2 = 5.4069
# CIE ΔE2000 = ΔE00 = 4.58236269566

# L1 = 81.2           a1 = 108.58         b1 = 30.0
# L2 = 87.2           a2 = 118.0          b2 = 20.361
# CIE ΔE2000 = ΔE00 = 5.72026793793

# L1 = 47.725         a1 = -92.2496       b1 = -30.732
# L2 = 58.227         a2 = -95.407        b2 = -29.8
# CIE ΔE2000 = ΔE00 = 10.28798824323

# L1 = 20.4           a1 = -19.1747       b1 = 104.57
# L2 = 7.12           a2 = 5.0            b2 = 117.332
# CIE ΔE2000 = ΔE00 = 14.84696457907

# L1 = 70.1           a1 = -74.479        b1 = -76.702
# L2 = 53.376         a2 = -126.6101      b2 = -46.8725
# CIE ΔE2000 = ΔE00 = 21.92730029885

# L1 = 72.0           a1 = 79.7775        b1 = -39.7597
# L2 = 84.445         a2 = 60.6767        b2 = -93.0
# CIE ΔE2000 = ΔE00 = 23.76489021114

# The output is intended to be checked by the Large-Scale validator
# at https://michel-leonard.github.io/ciede2000/batch.html

main <- function(n = 10000) {
	set.seed(NULL)

	results <- vector("numeric", n)

	for (i in 1:n) {
		l1 <- runif(1, 0, 100)
		a1 <- runif(1, -128, 128)
		b1 <- runif(1, -128, 128)
		l2 <- runif(1, 0, 100)
		a2 <- runif(1, -128, 128)
		b2 <- runif(1, -128, 128)
		
		l1 <- round(l1, sample(0:1, 1))
		a1 <- round(a1, sample(0:1, 1))
		b1 <- round(b1, sample(0:1, 1))
		l2 <- round(l2, sample(0:1, 1))
		a2 <- round(a2, sample(0:1, 1))
		b2 <- round(b2, sample(0:1, 1))
		
		delta_e <- ciede_2000(l1, a1, b1, l2, a2, b2)
		results[i] <- delta_e
		
		cat(sprintf("%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.15f\n", l1, a1, b1, l2, a2, b2, delta_e))
	}
}

main()
