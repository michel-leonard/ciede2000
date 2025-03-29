# CIEDE2000 Color-Difference

This software is not affiliated with the CIE (International Commission on Illumination), has not been validated by it, and is released into the **public domain**. It is provided "as is" without any warranty.

## Status

Ready to be deployed in **production** environments.

## Version

This document describes the **CIE ΔE00** functions v1.0.0, released on March 1, 2025.

![the CIEDE2000 formula, based on CIE Technical Report 142-2001](docs/images/delta-e-2000.jpg)

## Cross-Language Consistency

The implementation of the ΔE 2000 consists of a single function with consistent results to **10 decimal places** in multiple programming languages :
- Python
- JavaScript — TypeScript
- C — C++
- Java — Kotlin
- Rust
- Go
- Julia
- MATLAB
- R
- Ruby
- Dart
- Swift
- Racket
- SQL
- Perl
- PHP
- Lua — LuaJIT
- VBA
- Excel

These classical implementations of the **CIEDE2000 color difference formula** are [completely](tests#comparison-with-university-of-rochester-worked-examples) consistent with the samples studied by Gaurav Sharma, Wencheng Wu, and Edul N. Dalal at the University of Rochester.

## Usage
Use the CIEDE2000 color difference formula in your programming language.

### Python
```python
# Example usage in Python
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

### JavaScript/TypeScript
```javascript
// Example usage in JavaScript
const deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);
```

### C/C++
```c
// Example usage in C
double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
printf("%f\n", deltaE);
```

### Java
```java
// Example usage in Java
double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
System.out.println(deltaE);
```

### Kotlin
```kt
// Example usage in Kotlin
val deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)
```

### Rust
```rs
// Example usage in Rust
let delta_e = ciede_2000(l1, a1, b1, l2, a2, b2);
println!("{}", delta_e);
```

### Go
```go
// Example usage in Go
deltaE := ciede_2000(l1, a1, b1, l2, a2, b2);
fmt.Printf("%f\n", deltaE);
```

### Julia
```jl
# Example usage in Julia
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
println(deltaE)
```

### MATLAB
```m
% Example usage in MATLAB
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
disp(deltaE);
```

### R
```r
# Example usage in R
delta_e <- ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

### Ruby
```ruby
# Example usage in Ruby
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
puts delta_e
```

### Dart
```dart
// Example usage in Dart
final double delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

### Swift
```swift
// Example usage in Swift
let delta_e = ciede_2000(l_1: l1, a_1: a1, b_1: b1, l_2: l2, a_2: a2, b_2: b2)
print(delta_e)
```

### Racket
```racket
; Example usage in Racket
(define delta-e (ciede_2000 l1 a1 b1 l2 a2 b2))
(displayln delta-e)
```

### SQL
```SQL
-- Example usage in SQL
SELECT ciede_2000(l1, a1, b1, l2, a2, b2) AS delta_e;
```

### Perl
```pl
# Example usage in Perl
my $deltaE = ciede_2000($l1, $a1, $b1, $l2, $a2, $b2);
print $deltaE;
```

### PHP
```php
// Example usage in PHP
$deltaE = ciede_2000($l1, $a1, $b1, $l2, $a2, $b2);
echo $deltaE;
```

### Lua/LuaJIT
```lua
-- Example usage in Lua
local deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
print(deltaE);
```

### VBA
```vba
' Example usage in VBA
Dim deltaE As Double
deltaE = ciede_2000(l1, a1, b1, l2, a2, b2)
Debug.Print deltaE
```

### Excel
When it comes to displaying color differences in **Microsoft Excel**, we update the six columns containing the color values (L\*, a\*, b\*) and drag the formula down to calculate as many ΔE 2000 values as necessary.

## Possible Usage

- **Precision**: Medical image processing (shade differences between healthy and diseased tissues).
- **Efficiency**: Machine vision (color-based quality control).
- **Everywhere**: Colorimetry in scientific research (studies on color perception).

The textile industry usually adjusts `k_l` to `2.0` in the source code for its needs.

### Live Examples

Based on our JavaScript implementation, you can see the CIEDE2000 color difference formula in action here :
- A [tool](https://michel-leonard.github.io/ciede2000) that identify the name of the selected color based on a picture.
- A [discovery generator](https://michel-leonard.github.io/ciede2000/samples.html) for quick, small-scale testing and exploration.
- A [large-scale generator](https://michel-leonard.github.io/ciede2000/batch.html) used to validate new implementations.
- A [simple calculator](https://michel-leonard.github.io/ciede2000/calculator.html) of the **ΔE 2000**, given two L\*a\*b\* colors.

## Testing and Validation

To ensure accurate color evaluation, [extensive testing](tests#ciede-2000-function-test) involving **1,365,000,000** comparisons has been conducted. Correctness and consistency of ΔE00 implementations across all programming languages ​​are essential in this project :

- **Test Cases**: Each programming language generates a CSV file containing **7,500,000** random samples.  
- **Tolerance**: All programming languages reproduce every sample, except their own, with a tolerance of 1e-10.  
- **Cross-Language Consistency**: This procedure could be respected and extended to new programming languages.

In other words, the absolute value of the difference between any two implementations does not exceed 1e-10.

### Numerical Stability in CIEDE2000

To confirm its exceptional accuracy, the JavaScript implementation was compared to an old and reliable reference, with no deviations greater than **1e-12** detected in ΔE00s across **80,000,000,000** random color pairs tested. Minor differences were attributed to degree-to-radian conversions in the reference calculations.

#### Angle Conversions

The professional approach in software is to use radians for mathematical calculations, because angle conversions, while theoretically valid, result in a loss of precision due to rounding errors in floating-point numbers. Here, only radians are used, without conversion, but this can be a source of inconsistencies for an external implementation.

#### IEEE 754 floating-point Limitations

Minor discrepancies can arise between programming languages, for instance, `atan2(-49.2, -34.9)` evaluates to `-2.1877696633888672` in Python and `-2.1877696633888677` in JavaScript, while `-2.187769663388867475...` is correct. So the threshold for an accepted cross-language exact match is set to `1e-10`, linking sufficiency and achievability.

#### Debugging

Rounding L\*a\*b\* components and ΔE 2000 to [4 decimal places](tests#roundings) can be a solution for realistic color comparisons.

### Performance Overview

Runtimes were recorded while calculating 100 million iterations of the color difference formula ΔE 2000.

| Language | Compilation Type | Duration (mm:ss) | Performance factor compared to C |
|:--:|:--:|:--:|:--:|
| C | Compiled| 00:45 | 1× (Reference) |
| Rust | Compiled | 00:52 | 1.15× slower |
| Go | Compiled | 00:52 | 1.15× slower |
| LuaJIT | Just-In-Time Compiled | 00:53 | 1.18× slower |
| Java | Just-In-Time Compiled | 00:57 | 1.25× slower |
| Kotlin |  Just-In-Time Compiled | 00:57 | 1.26× slower |
| MATLAB | Interpreted | 01:06 | 1.46× slower |
| TypeScript | Just-In-Time Compiled| 01:17 | 1.7× slower |
| JavaScript | Just-In-Time Compiled | 01:18 | 1.73× slower |
| PHP | Interpreted | 03:28 | 4.57× slower |
| Lua | Interpreted | 07:03 | 9.36× slower |
| Ruby | Interpreted | 07:20 | 9.65× slower |
| Perl | Interpreted | 08:20 | 12.44× slower |
| Python | Interpreted | 10:13 | 13.45× slower |
| SQL | Database Query Language | 22:17 | 29.71× slower |
| VBA | Interpreted | 11:35:00 | 935.56× slower |

## Contributing

Here are some examples of programming languages that could be used to expand the `ciede_2000` function :
- C#

### Methodology

To ensure consistency across implementations, please follow these guidelines :
1. **Base your implementation** on an existing one, copy-pasting and adapting is encouraged.
2. **Validate correctness** basically using the [discovery generator](https://michel-leonard.github.io/ciede2000/samples.html), and formally using the [large-scale generator](https://michel-leonard.github.io/ciede2000/batch.html) :
   - Generate 1,000,000 samples, or 100,000 if you encounter technical limitations.
   - Verify that the computed ΔE 2000 values do not deviate by more than **1e-10** from reference values.
3. **Submit a pull request** with your implementation.

To enhance your contribution, consider writing documentation, as done for other programming languages. Your source code, along with the others, will then be reviewed and made available in this public domain repository.

> [!NOTE]
> If the `atan2` function is not available in your chosen language, you can use the polyfill provided in the [VBA](ciede-2000.bas#L24) version. Similarly, when `hypot` is not available, the polyfill template can be found in the [Lua](ciede-2000.lua#L15) version.

### Other way to contribute

Purchase the original CIE Technical Report [142-2001](https://store.accuristech.com/cie/standards/cie-142-2001?product_id=1210060). This document, without which this repository would not exist, specifically presents and formalizes the ΔE 2000 formula, providing guidelines on how to implement it.

## The L\*a\*b\* Color Range

- **L\*** nominally ranges from 0 (white) to 100 (black)
- **a\*** is unbounded and commonly clamped to the range of -128 (green) to 127 (red)
- **b\*** is unbounded and commonly clamped to the range of -128 (blue) to 127 (yellow)

## Short URL
Quickly share this GitHub project permanently using [bit.ly/ciede2000](https://bit.ly/ciede2000).
