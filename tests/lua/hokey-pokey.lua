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

-- GitHub Project : https://github.com/michel-leonard/ciede2000
--  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

-- L1 = 92.0           a1 = 46.3           b1 = 60.82
-- L2 = 92.0           a2 = 46.27          b2 = 60.82
-- CIE ΔE2000 = ΔE00 = 0.01435892951

-- L1 = 82.0           a1 = -125.6681      b1 = -60.56
-- L2 = 82.0           a2 = -126.0         b2 = -60.56
-- CIE ΔE2000 = ΔE00 = 0.05933965002

-- L1 = 24.44          a1 = 116.6956       b1 = -53.934
-- L2 = 29.0           a2 = 116.6956       b2 = -57.405
-- CIE ΔE2000 = ΔE00 = 3.51070512263

-- L1 = 36.726         a1 = -89.0          b1 = 87.9
-- L2 = 41.0           a2 = -85.488        b2 = 91.8
-- CIE ΔE2000 = ΔE00 = 3.99282930475

-- L1 = 35.2           a1 = -58.408        b1 = 10.051
-- L2 = 40.08          a2 = -58.408        b2 = 10.051
-- CIE ΔE2000 = ΔE00 = 4.1555292153

-- L1 = 33.69          a1 = -19.57         b1 = -59.7898
-- L2 = 46.32          a2 = 16.2808        b2 = -112.1357
-- CIE ΔE2000 = ΔE00 = 16.15260995363

-- L1 = 50.5           a1 = -88.101        b1 = 50.618
-- L2 = 32.0148        a2 = -115.584       b2 = 112.7672
-- CIE ΔE2000 = ΔE00 = 20.56366364394

-- L1 = 68.0           a1 = 124.7773       b1 = 43.0
-- L2 = 70.35          a2 = 45.0           b2 = 49.814
-- CIE ΔE2000 = ΔE00 = 24.93168963955

-- L1 = 14.76          a1 = 94.3           b1 = 55.0
-- L2 = 55.0           a2 = 36.0659        b2 = -98.0
-- CIE ΔE2000 = ΔE00 = 59.82983251036

-- L1 = 11.0           a1 = -71.31         b1 = 55.5819
-- L2 = 97.2           a2 = 119.0          b2 = 125.4214
-- CIE ΔE2000 = ΔE00 = 116.32947719024

-- ///////////////////////////////////////////////
-- ///////////////////////////////////////////////
-- ///////////////////////////////////////////////
-- //////////				 /////////////
-- //////////		 TESTING	 /////////////
-- //////////				 /////////////
-- ///////////////////////////////////////////////
-- ///////////////////////////////////////////////
-- ///////////////////////////////////////////////

function random_range(lo, hi)
	local val = lo + math.random() * (hi - lo);
	return math.floor(val * 1000.0 + 0.5) / 1000.0;
end

function prepare_values(iterations)
	iterations = iterations or 10000;
	local file = io.open("./values-lua.txt", "w");
	print(string.format("prepare_values('./values-lua.txt', %d)", iterations))
	local j = 0;
	for i = 1, iterations do
		local l1 = random_range(0.0, 100.0);
		local a1 = random_range(-128.0, 128.0);
		local b1 = random_range(-128.0, 128.0);
		local l2 = random_range(0.0, 100.0);
		local a2 = random_range(-128.0, 128.0);
		local b2 = random_range(-128.0, 128.0);
		local delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
		file:write(string.format("%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.15f\n", l1, a1, b1, l2, a2, b2, delta_e));
		j = j + 1;
		if j == 1000 then
			j = 0;
			io.write(".");
			io.flush();
		end
	end
	file:close();
end

function compare_values(folder)
	local filename = "./../" .. folder .. "/values-" .. folder .. ".txt";
	print(string.format("compare_values('%s')", filename))
	local file = io.open(filename, "r");
	
	if not file then
		print("Error : Can't open the file " .. filename);
		return;
	end

	local error_count = 0;
	local comparison_count = 0;
	local j = 0;
	
	for line in file:lines() do
		local iterator = string.gmatch(line, "([^,]+)"); -- LuaJIT
		-- local iterator = string.gfind(line, "([^,]+)"); -- Lua 5.0
		local l_1 = tonumber(iterator());
		local a_1 = tonumber(iterator());
		local b_1 = tonumber(iterator());
		local l_2 = tonumber(iterator());
		local a_2 = tonumber(iterator());
		local b_2 = tonumber(iterator());
		local expected_result = tonumber(iterator());
		local result = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);
		
		if not (result and math.abs(result - expected_result) <= 1e-10) then
			print(string.format("Error at line %d - Expected : %.12f, Found : %.12f", 
								comparison_count + 1, expected_result, result));
			error_count = error_count + 1;
		end

		if error_count >= 10 then
			print("10 errors limit reached.");
			break;
		end

		comparison_count = comparison_count + 1
		j = j + 1;
		if j == 1000 then
			j = 0;
			io.write(".");
			io.flush();
		end
	end
	file:close();
end

local num = tonumber(arg[1])

if num and 0 <= num and num <= 10000000 then
	prepare_values(num)
elseif arg[1] and string.find(arg[1], "%a+") then
	compare_values(arg[1])
else
	print("Usage: lua script.lua <positive_integer> or <string>")
	print("If a positive integer is provided, 'prepare_values' will be called.")
	print("If a string is provided, 'compare_values' will be called.")
	print("Otherwise, the script will display this help message.")
end
