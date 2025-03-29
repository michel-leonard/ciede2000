% hokey-pokey.m

% This function written in MATLAB is not affiliated with the CIE (International Commission on Illumination),
% and is released into the public domain. It is provided "as is" without any warranty, express or implied.

function delta_e = ciede_2000_classic(l_1, a_1, b_1, l_2, a_2, b_2)
	% This scalar expansion wrapper works with numbers, not vectors.
	delta_e = ciede_2000([l_1], [a_1], [b_1], [l_2], [a_2], [b_2]);
	delta_e = delta_e(1);
end

% The classic vectorized CIE ΔE implementation, ΔE2000 (ΔE00).
function delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2)
	% Working with MATLAB and the CIEDE2000 color-difference formula.
	% k_l, k_c, k_h are parametric factors to be adjusted according to
	% different viewing parameters such as textures, backgrounds...
	k_l = 1.0; k_c = 1.0; k_h = 1.0;
	n = (hypot(a_1, b_1) + hypot(a_2, b_2)) * 0.5;
	n = n .* n .* n .* n .* n .* n .* n;
	% A factor involving chroma raised to the power of 7 designed to make
	% the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - sqrt(n ./ (n + 6103515625.0)));
	% hypot calculates the Euclidean distance while avoiding overflow/underflow.
	c_1 = hypot(a_1 .* n, b_1);
	c_2 = hypot(a_2 .* n, b_2);
	% atan2 is preferred over atan because it accurately computes the angle of
	% a point (x, y) in all quadrants, handling the signs of both coordinates.
	h_1 = atan2(b_1, a_1 .* n);
	h_2 = atan2(b_2, a_2 .* n);
	% Vectorized conditionals
	m_1 = h_1 < 0.0;
	m_2 = h_2 < 0.0;
	h_1(m_1) = h_1(m_1) + 2.0 * pi;
	h_2(m_2) = h_2(m_2) + 2.0 * pi;
	n = abs(h_2 - h_1);
	% Cross-implementation consistent rounding.
	n((pi - 1E-14 < n) & (n < pi + 1E-14)) = pi;
	% When the hue angles lie in different quadrants, the straightforward
	% average can produce a mean that incorrectly suggests a hue angle in
	% the wrong quadrant, the next lines handle this issue.
	h_m = 0.5 * h_1 + 0.5 * h_2;
	h_d = (h_2 - h_1) * 0.5;	
	% Vectorized conditionals
	m_1 = pi < n;
	m_2 = 0.0 < h_d;
	m_3 = m_1 & m_2;
	h_d(m_3) = h_d(m_3) - pi;
	m_3 = m_1 & ~m_2;
	h_d(m_3) = h_d(m_3) + pi;
	h_m(m_1) = h_m(m_1) + pi;
	p = (36.0 * h_m - 55.0 * pi);
	n = (c_1 + c_2) * 0.5;
	n = n .* n .* n .* n .* n .* n .* n;
	% The hue rotation correction term is designed to account for the
	% non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * sqrt(n ./ (n + 6103515625.0)) .* sin(pi / 3.0 * exp((p .* p) / (-25.0 * pi * pi)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) .* (n - 50.0);
	% Lightness.
	l = (l_2 - l_1) ./ (k_l .* (1.0 + 0.015 * n ./ sqrt(20.0 + n)));
	% These coefficients adjust the impact of different harmonic
	% components on the hue difference calculation.
	t = 1.0 + 0.24 * sin(2.0 * h_m + pi / 2.0) + 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0) - 0.17 .* sin(h_m + pi / 3.0) - 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
	n = c_1 + c_2;
	% Hue.
	h = 2.0 * sqrt(c_1 .* c_2) .* sin(h_d) ./ (k_h .* (1.0 + 0.0075 * n .* t));
	% Chroma.
	c = (c_2 - c_1) ./ (k_c .* (1.0 + 0.0225 * n));
	% Returning the square root ensures that the result represents
	% the "true" geometric distance in the color space.
	delta_e = sqrt(l .* l + h .* h + c .* c + c .* h .* r_t);
end

% GitHub Project : https://github.com/michel-leonard/ciede2000
%  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

% L1 = 31.72          a1 = 118.942        b1 = -76.184
% L2 = 31.72          a2 = 119.0          b2 = -76.184
% CIE ΔE2000 = ΔE00 = 0.01095104353

% L1 = 89.6           a1 = 104.885        b1 = -27.3
% L2 = 90.0           a2 = 104.885        b2 = -26.5017
% CIE ΔE2000 = ΔE00 = 0.34281746731

% L1 = 76.9           a1 = 123.02         b1 = -126.76
% L2 = 76.9           a2 = 124.6          b2 = -126.76
% CIE ΔE2000 = ΔE00 = 0.36453766128

% L1 = 74.8           a1 = 112.1          b1 = -100.024
% L2 = 74.8           a2 = 104.6301       b2 = -93.1472
% CIE ΔE2000 = ΔE00 = 1.35164141936

% L1 = 33.89          a1 = -83.5925       b1 = -80.3
% L2 = 33.89          a2 = -83.5925       b2 = -72.1932
% CIE ΔE2000 = ΔE00 = 1.92955093366

% L1 = 45.0           a1 = 113.074        b1 = -6.476
% L2 = 47.975         a2 = 107.52         b2 = -11.0
% CIE ΔE2000 = ΔE00 = 3.36232583779

% L1 = 82.0           a1 = -48.0          b1 = 97.0166
% L2 = 88.7           a2 = -48.0          b2 = 98.3569
% CIE ΔE2000 = ΔE00 = 4.4007871638

% L1 = 53.1           a1 = 125.6          b1 = 68.38
% L2 = 58.1841        a2 = 125.6          b2 = 68.38
% CIE ΔE2000 = ΔE00 = 4.7678806364

% L1 = 83.6           a1 = 82.0           b1 = -81.751
% L2 = 87.0           a2 = 79.6932        b2 = -36.9177
% CIE ΔE2000 = ΔE00 = 13.97547485919

% L1 = 99.8           a1 = 42.0           b1 = -67.7456
% L2 = 61.285         a2 = 114.07         b2 = 58.387
% CIE ΔE2000 = ΔE00 = 50.48369780719

function prepare_values(num_lines)

	if nargin < 1
		num_lines = 10000;
	end

	rand("state", sum(100.0 * clock));
	
	path = './values-m.txt' ;

	if exist(path, 'file')
		delete(path);
	end
	
	fprintf("prepare_values('%s', %d)\n", path, num_lines);

	chunk_size = 25000;
	num_chunks = ceil(num_lines / chunk_size);

	for chunk = 1:num_chunks
		start_idx = (chunk - 1) * chunk_size + 1;
		end_idx = min(chunk * chunk_size, num_lines);

		num_in_chunk = end_idx - start_idx + 1;

		l_1 = round_to_random_decimals(rand(num_in_chunk, 1) * 100);
		a_1 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);
		b_1 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);
		l_2 = round_to_random_decimals(rand(num_in_chunk, 1) * 100);
		a_2 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);
		b_2 = round_to_random_decimals(rand(num_in_chunk, 1) * 256 - 128);

		delta_e = ciede_2000(l_1, a_1, b_1, l_2, a_2, b_2);

		dlmwrite(path, [l_1, a_1, b_1, l_2, a_2, b_2, delta_e], '-append');

		for i = 1:chunk_size / 1000
			fprintf('.');
		end
	end
	disp('');
end

function rounded_value = round_to_random_decimals(value)
	switch randi([0, 2])
		case 0
			rounded_value = round(value);
		case 1
			rounded_value = round(value * 10.0) / 10.0;
		otherwise
			rounded_value = round(value * 100.0) / 100.0;
	end
end

function compare_values(arg)

	path = sprintf('./../%s/values-%s.txt', arg, arg);

	fprintf("compare_values('%s')\n", path);

	error_count = 0;
	chunk_size = 25000;
	start_row = 0;

	while true
		try
			chunk_data = dlmread(path, ',', [start_row 0 (start_row + chunk_size - 1) 6]);
		catch
			break;
		end

		if isempty(chunk_data)
			break;
		end

		L1 = chunk_data(:, 1);
		a1 = chunk_data(:, 2);
		b1 = chunk_data(:, 3);
		L2 = chunk_data(:, 4);
		a2 = chunk_data(:, 5);
		b2 = chunk_data(:, 6);
		expected_delta_e = chunk_data(:, 7);

		delta_e = ciede_2000(L1, a1, b1, L2, a2, b2);

		for i = 1:numel(delta_e)
			if abs(delta_e(i) - expected_delta_e(i)) > 1e-10
				fprintf('Error: ΔE = %f, got %f at index %d\n', delta_e(i), expected_delta_e(i), i);
				error_count = error_count + 1;
				
				if error_count >= 10
					fprintf('More than 10 errors, stopping.\n');
					return;
				end
			end
		end

		for i = 1:chunk_size / 1000
			fprintf('.');
		end

		start_row = start_row + chunk_size;
	end
	
	disp('');
end

if numel(argv) < 1
	error('A parameter is required.');
end

str = argv{1};
num = str2num(str);

if all(isdigit(str)) && 1 <= num && num <= 10000000
	prepare_values(num);
elseif ischar(str) && all(isletter(str))
	compare_values(str);
else
	disp('Error, the parameter must be well formed.');
end
