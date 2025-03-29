# Color Converters

This repository provides functions for converting between RGB, XYZ, and CIE Lab color spaces.

## Functions

This project focuses on CIE ΔE 2000 cross-language implementation, these converters are provided as a convenience for users.

| Function Signature | Description |
|:--:|:--:|
| `rgb_to_xyz(r, g, b)` | Converts RGB values (0-255 range) to the XYZ color space. |
| `xyz_to_lab(x, y, z)` | Converts XYZ values to the CIELAB (Lab) color space. |
| `rgb_to_lab(r, g, b)` | Converts RGB values directly to Lab. |
| `lab_to_xyz(l, a, b)` | Converts Lab values back to the XYZ color space. |
| `xyz_to_rgb(x, y, z)` | Converts XYZ values back to the RGB color space. |
| `lab_to_rgb(l, a, b)` | Converts Lab values directly to RGB. |

## Color Conversion Constants

These constants found in the source code are most of the time transparently optimized by the compiler.

| Fraction | Computed Value |
|:--:|:--:|
| 216.0 / 24389.0 | 0.0088564516790356308171716757554635286399606379925376194185903481077 |
| 841.0 / 108.0 | 7.78703703703703703703703703703703703703703703703703703703703703703703703703 |
| 4.0 / 29.0 | 0.13793103448275862068965517241379310344827586206896551724137931034482758620 |
| 24389.0 / 27.0 | 903.296296296296296296296296296296296296296296296296296296296296296296296296 |
| 1.0 / 2.4 | 0.41666666666666666666666666666666666666666666666666666666666666666666666666 |


## Development

Progress can be made by :
- Implementing these color space converters in other programming languages (Python, Java, Go, etc.)​.
- Implementing tests for all conversion functions.
