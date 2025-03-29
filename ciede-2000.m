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
	h_m = (h_1 + h_2) * 0.5;
	h_d = (h_2 - h_1) * 0.5;
	% Vectorized conditionals
	m_1 = pi < n;
	m_2 = 0.0 < h_d;
	m_3 = m_1 & m_2;
	h_d(m_3) = h_d(m_3) - pi;
	m_3 = m_1 & ~m_2;
	h_d(m_3) = h_d(m_3) + pi;
	h_m(m_1) = h_m(m_1) + pi;
	p = 36.0 * h_m - 55.0 * pi;
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
	t = 1.0	+ 0.24 * sin(2.0 * h_m + pi * 0.5) ...
 		+ 0.32 * sin(3.0 * h_m + 8.0 * pi / 15.0) ...
   		- 0.17 .* sin(h_m + pi / 3.0) ...
     		- 0.20 * sin(4.0 * h_m + 3.0 * pi / 20.0);
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

% L1 = 85.0           a1 = -46.0          b1 = -126.0
% L2 = 85.0           a2 = -46.0          b2 = -126.126
% CIE ΔE2000 = ΔE00 = 0.01644386698

% L1 = 72.54          a1 = 108.5          b1 = 2.9
% L2 = 72.54          a2 = 102.2          b2 = 2.9
% CIE ΔE2000 = ΔE00 = 1.09813674492

% L1 = 62.99          a1 = 122.0          b1 = 93.0
% L2 = 62.99          a2 = 122.0          b2 = 98.9122
% CIE ΔE2000 = ΔE00 = 1.7887048471

% L1 = 56.81          a1 = 37.124         b1 = 0.746
% L2 = 60.9           a2 = 37.124         b2 = 5.444
% CIE ΔE2000 = ΔE00 = 4.57556897189

% L1 = 56.1           a1 = -16.041        b1 = -87.12
% L2 = 51.48          a2 = -21.0          b2 = -92.36
% CIE ΔE2000 = ΔE00 = 5.07782962291

% L1 = 52.5           a1 = -69.0          b1 = -42.1272
% L2 = 43.0           a2 = -85.47         b2 = -56.08
% CIE ΔE2000 = ΔE00 = 10.30395457958

% L1 = 76.0           a1 = 76.0           b1 = -27.98
% L2 = 89.0           a2 = 33.0           b2 = -21.9003
% CIE ΔE2000 = ΔE00 = 15.36865259476

% L1 = 35.0867        a1 = -2.53          b1 = 108.6
% L2 = 43.7           a2 = -54.5772       b2 = 120.0
% CIE ΔE2000 = ΔE00 = 21.84311520587

% L1 = 79.3           a1 = 62.0871        b1 = 21.2
% L2 = 54.3091        a2 = 82.294         b2 = -5.0
% CIE ΔE2000 = ΔE00 = 23.87969857874

% L1 = 68.61          a1 = -52.22         b1 = 18.3514
% L2 = 3.41           a2 = -26.0884       b2 = 45.78
% CIE ΔE2000 = ΔE00 = 57.2043848421
