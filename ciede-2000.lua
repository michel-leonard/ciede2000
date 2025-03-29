-- This function written in Lua is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

-- The classic CIE ΔE implementation, ΔE2000 (ΔE00).
function ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	-- Working with Lua/LuaJIT and the CIEDE2000 color-difference formula.
	-- k_l, k_c, k_h are parametric factors to be adjusted according to
	-- different viewing parameters such as textures, backgrounds...
	local k_l, k_c, k_h = 1.0, 1.0, 1.0;
	local n = (math.sqrt(a_1 * a_1 + b_1 * b_1) + math.sqrt(a_2 * a_2 + b_2 * b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	-- A factor involving chroma raised to the power of 7 designed to make
	-- the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - math.sqrt(n / (n + 6103515625.0)));
	-- hypot from Lua 5.4, rather than sqrt used here can calculate
	-- Euclidean distance while avoiding overflow/underflow.
	local c_1 = math.sqrt(a_1 * a_1 * n * n + b_1 * b_1);
	local c_2 = math.sqrt(a_2 * a_2 * n * n + b_2 * b_2);
	-- atan2 is preferred over atan because it accurately computes the angle of
	-- a point (x, y) in all quadrants, handling the signs of both coordinates.
	local h_1 = math.atan2(b_1, a_1 * n);
	local h_2 = math.atan2(b_2, a_2 * n);
	if h_1 < 0.0 then h_1 = h_1 + 2.0 * math.pi end;
	if h_2 < 0.0 then h_2 = h_2 + 2.0 * math.pi end;
	n = math.abs(h_2 - h_1);
	-- Cross-implementation consistent rounding.
	if math.pi - 1E-14 < n and n < math.pi + 1E-14 then n = math.pi end;
	-- When the hue angles lie in different quadrants, the straightforward
	-- average can produce a mean that incorrectly suggests a hue angle in
	-- the wrong quadrant, the next lines handle this issue.
	local h_m = (h_1 + h_2) * 0.5;
	local h_d = (h_2 - h_1) * 0.5;
	if math.pi < n then
		if 0.0 < h_d then
			h_d = h_d - math.pi;
		else
			h_d = h_d + math.pi;
		end
		h_m = h_m + math.pi;
	end
	local p = 36.0 * h_m - 55.0 * math.pi;
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	-- The hue rotation correction term is designed to account for the
	-- non-linear behavior of hue differences in the blue region.
	local r_t = -2.0 * math.sqrt(n / (n + 6103515625.0)) *
			math.sin(math.pi / 3.0 * math.exp(p * p / (-25.0 * math.pi * math.pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	-- Lightness.
	local l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / math.sqrt(20.0 + n)));
	-- These coefficients adjust the impact of different harmonic
	-- components on the hue difference calculation.
	local t = 1.0	+ 0.24 * math.sin(2.0 * h_m + math.pi * 0.5)
			+ 0.32 * math.sin(3.0 * h_m + 8.0 * math.pi / 15.0)
			- 0.17 * math.sin(h_m + math.pi / 3.0)
			- 0.20 * math.sin(4.0 * h_m + 3.0 * math.pi / 20.0);
	n = c_1 + c_2;
	-- Hue.
	local h = 2.0 * math.sqrt(c_1 * c_2) * math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	-- Chroma.
	local c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	-- Returning the square root ensures that the result represents
	-- the "true" geometric distance in the color space.
	return math.sqrt(l * l + h * h + c * c + c * h * r_t);
end

-- GitHub Project : https://github.com/michel-leonard/ciede2000
--  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

-- L1 = 95.29          a1 = -3.39          b1 = -86.0
-- L2 = 95.29          a2 = -3.467         b2 = -85.867
-- CIE ΔE2000 = ΔE00 = 0.02415836206

-- L1 = 61.0943        a1 = 89.0284        b1 = 14.7
-- L2 = 61.0943        a2 = 89.0284        b2 = 16.71
-- CIE ΔE2000 = ΔE00 = 0.78029814793

-- L1 = 80.0           a1 = 106.0          b1 = -52.5035
-- L2 = 80.0           a2 = 106.0          b2 = -47.124
-- CIE ΔE2000 = ΔE00 = 1.48298137103

-- L1 = 34.0498        a1 = 33.0           b1 = -17.8168
-- L2 = 37.0           a2 = 33.0           b2 = -16.9772
-- CIE ΔE2000 = ΔE00 = 2.48452724192

-- L1 = 82.9269        a1 = 118.16         b1 = 83.6
-- L2 = 87.7865        a2 = 126.7          b2 = 83.6
-- CIE ΔE2000 = ΔE00 = 3.7673707388

-- L1 = 59.0           a1 = -106.0         b1 = -14.0
-- L2 = 58.0           a2 = -62.0          b2 = -11.0
-- CIE ΔE2000 = ΔE00 = 9.30625062602

-- L1 = 65.3446        a1 = -57.0          b1 = -111.24
-- L2 = 64.0           a2 = -49.0          b2 = -58.79
-- CIE ΔE2000 = ΔE00 = 10.39144438081

-- L1 = 19.6677        a1 = -66.916        b1 = -110.8
-- L2 = 21.0           a2 = -14.0          b2 = -110.0
-- CIE ΔE2000 = ΔE00 = 15.88886772739

-- L1 = 55.99          a1 = -121.5         b1 = -13.13
-- L2 = 44.05          a2 = -73.47         b2 = -28.21
-- CIE ΔE2000 = ΔE00 = 17.66017606425

-- L1 = 21.94          a1 = -48.0          b1 = 31.694
-- L2 = 2.65           a2 = -1.9617        b2 = -75.538
-- CIE ΔE2000 = ΔE00 = 54.93772941562
