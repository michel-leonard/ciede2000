-- This function written in SQL is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

DELIMITER //

-- The classic CIE ΔE implementation, ΔE2000 (ΔE00).
CREATE OR REPLACE FUNCTION ciede_2000(l_1 DOUBLE, a_1 DOUBLE, b_1 DOUBLE, l_2 DOUBLE, a_2 DOUBLE, b_2 DOUBLE)
RETURNS DOUBLE
DETERMINISTIC
NO SQL
BEGIN
	-- Working with SQL/PSM and the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	DECLARE k_l, k_c, k_h DOUBLE DEFAULT 1.0;
	DECLARE n, c_1, c_2, h_1, h_2, h_m, h_d, r_t, p, t, l, c, h DOUBLE;

	SET n = (SQRT(a_1 * a_1 + b_1 * b_1) + SQRT(a_2 * a_2 + b_2 * b_2)) * 0.5;
	SET n = n * n * n * n * n * n * n;
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	SET n = 1.0 + 0.5 * (1.0 - SQRT(n / (n + 6103515625.0)));
	-- Since hypot is not available, sqrt is used here to calculate the
	-- Euclidean distance, without avoiding overflow/underflow.
	SET c_1 = SQRT(a_1 * a_1 * n * n + b_1 * b_1);
	SET c_2 = SQRT(a_2 * a_2 * n * n + b_2 * b_2);
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	SET h_1 = ATAN2(b_1, a_1 * n);
	SET h_2 = ATAN2(b_2, a_2 * n);
	IF h_1 < 0 THEN SET h_1 = h_1 + 2 * PI(); END IF;
	IF h_2 < 0 THEN SET h_2 = h_2 + 2 * PI(); END IF;
	SET n = ABS(h_2 - h_1);
	-- Cross-implementation consistent rounding.
	IF PI() - 1E-14 < n AND n < PI() + 1E-14 THEN SET n = PI(); END IF;
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	SET h_m = (h_1 + h_2) * 0.5;
	SET h_d = (h_2 - h_1) * 0.5;
	IF PI() < n THEN
		IF 0.0 < h_d THEN
			SET h_d = h_d - PI();
		ELSE
			SET h_d = h_d + PI();
		END IF;
		SET h_m = h_m + PI();
	END IF;
	SET p = 36.0 * h_m - 55.0 * PI();
	SET n = (c_1 + c_2) * 0.5;
	SET n = n * n * n * n * n * n * n;
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	SET r_t = -2.0 * SQRT(n / (n + 6103515625.0)) * SIN(PI() / 3.0 * EXP(p * p / (-25.0 * PI() * PI())));
	SET n = (l_1 + l_2) * 0.5;
	SET n = (n - 50.0) * (n - 50.0);
	-- Lightness.
	SET l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / SQRT(20.0 + n)));
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	SET t = 1.0	+ 0.24 * SIN(2.0 * h_m + PI() * 0.5)
			+ 0.32 * SIN(3.0 * h_m + 8.0 * PI() / 15.0)
			- 0.17 * SIN(h_m + PI() / 3.0)
			- 0.20 * SIN(4.0 * h_m + 3.0 * PI() / 20.0);
	SET n = c_1 + c_2;
	-- Hue.
	SET h = 2.0 * SQRT(c_1 * c_2) * SIN(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	-- Chroma.
	SET c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	-- Returning the square root ensures that the result represents
	-- the "true" geometric distance in the color space.
	RETURN SQRT(l * l + h * h + c * c + c * h * r_t);
END //

DELIMITER ;

-- GitHub Project : https://github.com/michel-leonard/ciede2000
--  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

-- L1 = 52.796         a1 = -29.0          b1 = -35.97
-- L2 = 52.796         a2 = -29.039        b2 = -35.97
-- CIE ΔE2000 = ΔE00 = 0.01695713267

-- L1 = 54.1           a1 = -105.104       b1 = -126.9
-- L2 = 54.1           a2 = -99.967        b2 = -126.9
-- CIE ΔE2000 = ΔE00 = 0.93051550526

-- L1 = 20.2           a1 = -102.0259      b1 = -71.3
-- L2 = 25.0           a2 = -102.0259      b2 = -66.9
-- CIE ΔE2000 = ΔE00 = 3.59784271147

-- L1 = 63.976         a1 = 121.1          b1 = 20.922
-- L2 = 66.0           a2 = 99.8           b2 = 6.706
-- CIE ΔE2000 = ΔE00 = 5.6481804785

-- L1 = 66.4           a1 = 3.9            b1 = -107.0
-- L2 = 64.416         a2 = 18.6114        b2 = -92.329
-- CIE ΔE2000 = ΔE00 = 11.24302787344

-- L1 = 27.2           a1 = 42.306         b1 = -127.4337
-- L2 = 14.2           a2 = 25.05          b2 = -72.02
-- CIE ΔE2000 = ΔE00 = 14.07609814533

-- L1 = 81.3           a1 = -107.0         b1 = 56.4709
-- L2 = 90.6368        a2 = -38.5          b2 = 15.0
-- CIE ΔE2000 = ΔE00 = 18.43419159026

-- L1 = 99.0           a1 = -25.4          b1 = -79.0
-- L2 = 56.0           a2 = -109.11        b2 = -4.3
-- CIE ΔE2000 = ΔE00 = 48.04696224321

-- L1 = 91.48          a1 = 57.71          b1 = -76.94
-- L2 = 8.005          a2 = -99.8          b2 = -115.1
-- CIE ΔE2000 = ΔE00 = 108.18289766063

-- L1 = 17.28          a1 = 90.075         b1 = -58.089
-- L2 = 89.4           a2 = -98.733        b2 = 86.047
-- CIE ΔE2000 = ΔE00 = 130.72601743422

