-- This function written in Lua is not affiliated with the CIE (International Commission on Illumination),
-- and is released into the public domain. It is provided "as is" without any warranty, express or implied.

-- Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
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
	local h_m = 0.5 * h_1 + 0.5 * h_2;
	local h_d = (h_2 - h_1) * 0.5;
	if math.pi < n then
		if 0.0 < h_d then
			h_d = h_d - math.pi;
		else
			h_d = h_d + math.pi;
		end
		h_m = h_m + math.pi;
	end
	local p = (36.0 * h_m - 55.0 * math.pi);
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
	local t = 1.0 + 0.24 * math.sin(2.0 * h_m + math.pi / 2.0)
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

-- More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
--
-- Testing lab(54.0, -49.0, -78.14) vs lab(54.0, -49.0, -78.14) expects ΔE2000 = ΔE00 = 0.0
-- Testing lab(72.054, 84.93, -37.0) vs lab(72.054, 84.93, -37.077) expects ΔE2000 = ΔE00 = 0.02488428546
-- Testing lab(18.0, -10.4, -93.94) vs lab(18.0, -10.4, -93.754) expects ΔE2000 = ΔE00 = 0.02915457489
-- Testing lab(41.3, -125.6349, 109.49) vs lab(41.3, -126.0, 109.49) expects ΔE2000 = ΔE00 = 0.06307308274
-- Testing lab(94.3, -56.76, -82.37) vs lab(94.3, -56.68, -81.907) expects ΔE2000 = ΔE00 = 0.09335769142
-- Testing lab(12.0, -11.69, 108.46) vs lab(12.0, -12.2, 108.46) expects ΔE2000 = ΔE00 = 0.24122526559
-- Testing lab(63.4718, 91.03, 87.763) vs lab(63.4718, 91.64, 89.7109) expects ΔE2000 = ΔE00 = 0.49909289627
-- Testing lab(67.8081, 66.1529, -90.85) vs lab(67.8081, 66.1529, -88.605) expects ΔE2000 = ΔE00 = 0.78888355437
-- Testing lab(32.6987, 63.4, -38.1) vs lab(32.6987, 66.992, -38.1) expects ΔE2000 = ΔE00 = 1.02227811001
-- Testing lab(88.16, -87.909, 41.0) vs lab(88.16, -87.909, 44.7) expects ΔE2000 = ΔE00 = 1.16160131067
-- Testing lab(22.0, 47.1676, 101.27) vs lab(22.0, 47.1676, 107.0) expects ΔE2000 = ΔE00 = 1.44437521438
-- Testing lab(49.3, -62.72, -63.004) vs lab(49.3, -68.884, -63.004) expects ΔE2000 = ΔE00 = 1.66706610944
-- Testing lab(77.1, 107.7637, 41.0) vs lab(79.729, 107.7637, 41.0) expects ΔE2000 = ΔE00 = 1.850060513
-- Testing lab(103.742, -85.9004, -123.1694) vs lab(107.617, -85.9004, -123.1694) expects ΔE2000 = ΔE00 = 2.11458430274
-- Testing lab(22.445, -53.0, -78.95) vs lab(24.6534, -53.0, -87.6437) expects ΔE2000 = ΔE00 = 2.42886879908
-- Testing lab(6.8724, -126.5158, 33.17) vs lab(11.401, -126.5158, 33.17) expects ΔE2000 = ΔE00 = 2.81399862966
-- Testing lab(125.0, -82.341, 64.121) vs lab(131.2, -82.341, 64.121) expects ΔE2000 = ΔE00 = 2.85769056494
-- Testing lab(91.0, -88.8, 8.6) vs lab(96.41, -88.8, 8.0) expects ΔE2000 = ΔE00 = 3.28401928373
-- Testing lab(8.814, 63.0, -9.885) vs lab(8.814, 63.0, -1.59) expects ΔE2000 = ΔE00 = 3.56140036184
-- Testing lab(93.3712, -117.8581, -88.37) vs lab(99.7, -117.8581, -92.0) expects ΔE2000 = ΔE00 = 3.8118887137
-- Testing lab(40.0, -10.0, 82.087) vs lab(40.0, -16.4182, 77.0) expects ΔE2000 = ΔE00 = 3.93978468698
-- Testing lab(119.2, 103.9, -119.4315) vs lab(127.7, 111.0, -126.1529) expects ΔE2000 = ΔE00 = 4.21411051981
-- Testing lab(122.84, 11.826, 125.0) vs lab(122.84, 2.323, 125.0) expects ΔE2000 = ΔE00 = 4.4637160566
-- Testing lab(93.9, -57.71, 37.0) vs lab(101.9, -57.71, 37.0) expects ΔE2000 = ΔE00 = 4.6636657501
-- Testing lab(81.0, -37.8, 101.1613) vs lab(77.9, -26.42, 99.48) expects ΔE2000 = ΔE00 = 4.99912028709
-- Testing lab(68.0933, -74.5041, -121.5212) vs lab(74.02, -87.0, -119.0) expects ΔE2000 = ΔE00 = 5.3261404711
-- Testing lab(104.62, 51.0, -72.092) vs lab(93.616, 45.0, -72.564) expects ΔE2000 = ΔE00 = 7.02554696063
-- Testing lab(74.104, 60.0852, -82.1848) vs lab(81.24, 82.0, -112.0631) expects ΔE2000 = ΔE00 = 7.67632279584
-- Testing lab(70.0, -82.0, -107.9) vs lab(75.7021, -64.0, -68.6) expects ΔE2000 = ΔE00 = 8.48037477544
-- Testing lab(78.5, -98.7, 28.31) vs lab(88.0, -121.23, 15.894) expects ΔE2000 = ΔE00 = 9.14085757984
-- Testing lab(93.698, -61.708, -127.59) vs lab(82.404, -36.104, -89.1) expects ΔE2000 = ΔE00 = 10.78243115416
-- Testing lab(77.0, 122.7, -103.8) vs lab(83.0421, 83.087, -51.0) expects ΔE2000 = ΔE00 = 11.91398175452
-- Testing lab(23.24, 58.7834, -85.0) vs lab(32.1828, 114.405, -125.818) expects ΔE2000 = ΔE00 = 12.83839415797
-- Testing lab(59.0, -80.88, -82.969) vs lab(47.0, -113.1741, -113.663) expects ΔE2000 = ΔE00 = 13.24144109478
-- Testing lab(89.5233, -34.5, -47.0) vs lab(108.45, -67.9, -80.4) expects ΔE2000 = ΔE00 = 15.00971854267
-- Testing lab(74.665, -58.107, -94.437) vs lab(91.1352, -120.7954, -117.8497) expects ΔE2000 = ΔE00 = 15.9077190011
-- Testing lab(102.4, 41.1, 40.078) vs lab(79.8227, 28.533, 43.9) expects ΔE2000 = ΔE00 = 16.14014008308
-- Testing lab(17.5143, -35.37, 97.82) vs lab(16.7, -91.46, 89.418) expects ΔE2000 = ΔE00 = 17.63516749774
-- Testing lab(113.0, -102.0, -103.72) vs lab(111.1, -25.4, -112.4) expects ΔE2000 = ΔE00 = 19.04293047094
-- Testing lab(96.0, 49.004, -2.224) vs lab(73.6555, 68.33, 25.383) expects ΔE2000 = ΔE00 = 19.76021311016
-- Testing lab(56.0, 115.45, -68.6715) vs lab(35.34, 91.93, -53.831) expects ΔE2000 = ΔE00 = 20.2377752662
-- Testing lab(84.253, 59.96, 9.618) vs lab(93.4426, 43.4, 42.11) expects ΔE2000 = ΔE00 = 21.35888249767
-- Testing lab(36.8, 89.418, 40.98) vs lab(13.2, 122.5, 12.16) expects ΔE2000 = ΔE00 = 22.13950443621
-- Testing lab(73.357, -56.5, -29.8959) vs lab(49.98, -81.883, -79.3) expects ΔE2000 = ΔE00 = 24.03085127618
-- Testing lab(75.856, -114.6, -40.19) vs lab(84.0832, -19.5, -19.68) expects ΔE2000 = ΔE00 = 24.756434996
-- Testing lab(70.0, 70.3, -102.06) vs lab(59.3452, 122.0, 21.5177) expects ΔE2000 = ΔE00 = 38.32041948473
-- Testing lab(31.959, -23.3596, -15.0) vs lab(61.5497, 119.7, 5.0) expects ΔE2000 = ΔE00 = 71.31300475445
-- Testing lab(126.9, -127.9, -92.0) vs lab(20.0, -113.38, -18.5) expects ΔE2000 = ΔE00 = 81.98665602348
-- Testing lab(4.4, 81.603, 66.08) vs lab(76.09, -93.4583, -8.3) expects ΔE2000 = ΔE00 = 101.76517816976
-- Testing lab(118.72, -95.0, -77.74) vs lab(117.81, 90.533, -4.0) expects ΔE2000 = ΔE00 = 128.36286377501

