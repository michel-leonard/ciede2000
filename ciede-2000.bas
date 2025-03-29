' This function written in VBA is not affiliated with the CIE (International Commission on Illumination),
' and is released into the public domain. It is provided "as is" without any warranty, express or implied.

Option Explicit

' The classic CIE ΔE implementation, ΔE2000 (ΔE00).
Public Function ciede_2000(l_1 As Double, a_1 As Double, b_1 As Double, l_2 As Double, a_2 As Double, b_2 As Double) As Double
	' Working with VBA and the CIEDE2000 color-difference formula.
	' k_l, k_c, k_h are parametric factors to be adjusted according to
	' different viewing parameters such as textures, backgrounds...
	Const PI = 3.14159265358979323846264338328, k_l = 1.0, k_c = 1.0, k_h = 1.0
	Dim n As Double, c_1 As Double, c_2 As Double, h_1 As Double, h_2 As Double
	Dim h_m As Double, h_d As Double, p As Double, r_t As Double, l As Double
	Dim t As Double, h As Double, c As Double
	n = (Sqr(a_1 * a_1 + b_1 * b_1) + Sqr(a_2 * a_2 + b_2 * b_2)) * 0.5
	n = n * n * n * n * n * n * n
	' A factor involving chroma raised to the power of 7 designed to make
	' the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Sqr(n / (n + 6103515625.0)))
	' Since hypot is not available, sqrt is used here to calculate the
	' Euclidean distance, without avoiding overflow/underflow.
	c_1 = Sqr(a_1 * a_1 * n * n + b_1 * b_1)
	c_2 = Sqr(a_2 * a_2 * n * n + b_2 * b_2)
	' Using 20 lines to simulate atan2, as VBA does not have this built-in.
	c = a_1 * n
	If 0 < c Then
		h_1 = Atn(b_1 / c)
	ElseIf c < 0 Then
		h_1 = Atn(b_1 / c) + PI * Sgn(b_1)
		If b_1 = 0 Then h_1 = h_1 + PI
	Else
		h_1 = PI * 0.5 * Sgn(b_1)
	EndIf
	c = a_2 * n
	If 0 < c Then
		h_2 = Atn(b_2 / c)
	ElseIf c < 0 Then
		h_2 = Atn(b_2 / c) + PI * Sgn(b_2)
		If b_2 = 0 Then h_2 = h_2 + PI
	Else
		h_2 = PI * 0.5 * Sgn(b_2)
	EndIf
	' The atan2 polyfill is complete.
	If h_1 < 0.0 Then h_1 = h_1 + 2.0 * PI
	If h_2 < 0.0 Then h_2 = h_2 + 2.0 * PI
	n = Abs(h_2 - h_1)
	' Cross-implementation consistent rounding.
	If PI - 1E-14 < n And n < PI + 1E-14 Then n = PI
	' When the hue angles lie in different quadrants, the straightforward
	' average can produce a mean that incorrectly suggests a hue angle in
	' the wrong quadrant, the next lines handle this issue.
	h_m = (h_1 + h_2) * 0.5
	h_d = (h_2 - h_1) * 0.5
	If PI < n Then
		If 0.0 < h_d Then h_d = h_d - PI Else h_d = h_d + PI
		h_m = h_m + PI
	End If
	p = 36.0 * h_m - 55.0 * PI
	n = (c_1 + c_2) * 0.5
	n = n * n * n * n * n * n * n
	' The hue rotation correction term is designed to account for the
	' non-linear behavior of hue differences in the blue region.
	r_t = -2.0 * Sqr(n / (n + 6103515625.0)) _
			* Sin(PI / 3.0 * Exp(p * p / (-25.0 * PI * PI)))
	n = (l_1 + l_2) * 0.5
	n = (n - 50.0) * (n - 50.0)
	' Lightness.
	l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Sqr(20.0 + n)))
	' These coefficients adjust the impact of different harmonic
	' components on the hue difference calculation.
	t = 1.0		+ 0.24 * Sin(2.0 * h_m + PI * 0.5) _
			+ 0.32 * Sin(3.0 * h_m + 8.0 * PI / 15.0) _
			- 0.17 * Sin(h_m + PI / 3.0) _
			- 0.2 * Sin(4.0 * h_m + 3.0 * PI / 20.0)
	n = c_1 + c_2
	' Hue.
	h = 2.0 * Sqr(c_1 * c_2) * Sin(h_d) / (k_h * (1.0 + 0.0075 * n * t))
	' Chroma.
	c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n))
	' Returning the square root ensures that the result represents
	' the "true" geometric distance in the color space.
	ciede_2000 = Sqr(l * l + h * h + c * c + c * h * r_t)
End Function

' GitHub Project : https://github.com/michel-leonard/ciede2000
'  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

' L1 = 36.0           a1 = 33.871         b1 = -45.0
' L2 = 36.0           a2 = 33.9           b2 = -45.0
' CIE ΔE2000 = ΔE00 = 0.01508877337

' L1 = 17.81          a1 = -96.5137       b1 = 16.82
' L2 = 17.81          a2 = -97.02         b2 = 16.82
' CIE ΔE2000 = ΔE00 = 0.09776430714

' L1 = 89.141         a1 = -124.0         b1 = 6.71
' L2 = 91.0           a2 = -124.0         b2 = 0.737
' CIE ΔE2000 = ΔE00 = 2.39476172534

' L1 = 21.77          a1 = -68.75         b1 = 0.4
' L2 = 25.69          a2 = -71.0          b2 = 0.4
' CIE ΔE2000 = ΔE00 = 2.87500344073

' L1 = 78.2           a1 = 29.2           b1 = -22.77
' L2 = 83.333         a2 = 29.2           b2 = -20.957
' CIE ΔE2000 = ΔE00 = 3.66289691156

' L1 = 74.5155        a1 = -4.4116        b1 = -119.1
' L2 = 74.5155        a2 = 2.6673         b2 = -110.17
' CIE ΔE2000 = ΔE00 = 4.40180111073

' L1 = 24.6754        a1 = 122.1792       b1 = 21.36
' L2 = 12.0           a2 = 88.4847        b2 = 13.143
' CIE ΔE2000 = ΔE00 = 10.52223172239

' L1 = 46.0           a1 = 95.9603        b1 = 17.42
' L2 = 52.5069        a2 = 54.2           b2 = 8.0
' CIE ΔE2000 = ΔE00 = 11.68257250846

' L1 = 84.0809        a1 = 106.6          b1 = 89.86
' L2 = 59.16          a2 = 104.1799       b2 = 91.89
' CIE ΔE2000 = ΔE00 = 18.95623917348

' L1 = 97.4667        a1 = -30.801        b1 = -124.2
' L2 = 43.8           a2 = -86.0          b2 = 104.0
' CIE ΔE2000 = ΔE00 = 91.25609112818
