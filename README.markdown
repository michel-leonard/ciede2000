# CIEDE2000 Color-Difference

This software is not affiliated with the CIE (International Commission on Illumination), has not been validated by it, and is released into the **public domain**. It is provided "as is" without any warranty.

## Status

Ready to be deployed in **production** environments.

## Version

This document describes the ΔE 2000 functions v1.0.0, released on March 1, 2025.

## Cross-Language Consistency

The implementation of the **CIE ΔE00** consists of a single function with consistent results to **10 decimal places** in multiple programming languages :
- C — C++
- Rust
- Go
- Java — Kotlin
- JavaScript — TypeScript
- Lua — LuaJIT
- Perl
- PHP
- Python
- Ruby

These classical implementations of the **CIEDE2000 color difference formula** are [completely](tests#comparison-with-university-of-rochester-worked-examples) consistent with the samples studied by Gaurav Sharma, Wencheng Wu, and Edul N. Dalal at the University of Rochester.

## Usage
Use the CIEDE2000 color difference formula in your programming language.

### C/C++
```c
// Example usage in C
double deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
printf("%f\n", deltaE);
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

### JavaScript
```javascript
// Example usage in JavaScript
const deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
console.log(deltaE);
```

### Lua/LuaJIT
```lua
-- Example usage in Lua
local deltaE = ciede_2000(l1, a1, b1, l2, a2, b2);
print(deltaE);
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

### Python
```python
# Example usage in Python
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
print(delta_e)
```

### Ruby
```ruby
# Example usage in Ruby
delta_e = ciede_2000(l1, a1, b1, l2, a2, b2)
puts delta_e
```

## Possible Usage

- **Precision**: Medical image processing (shade differences between healthy and diseased tissues).
- **Efficiency**: Machine vision (color-based quality control).
- **Everywhere**: Colorimetry in scientific research (studies on color perception).

The textile industry usually adjusts `k_l` to `2.0` in the source code for its needs.

### Live Examples

Based on our JavaScript implementation, you can see the CIEDE2000 color difference formula in action here :
- [Tool](https://michel-leonard.github.io/ciede2000) that identify the name of the selected color based on a picture.
- [Generator](https://michel-leonard.github.io/ciede2000/samples.html) for testing and comparing different implementations.
- Simple [calculator](https://michel-leonard.github.io/ciede2000/calculator.html) of the **ΔE 2000**, given two L\*a\*b\* colors.

## Testing and Validation

To ensure **accurate color evaluation**, [extensive testing](tests#ciede-2000-function-test) involving 900,000,000 comparisons has been conducted. The correctness and consistency of the implementations across programming languages is the essence of this project :
- **Test Cases**: Each programming language generates a set of 10,000,000 random samples in a CSV file.
- **Tolerance**: All programming languages ​​reproduce all samples except their own, with a tolerance of 1e-10.
- **Cross-Language**: This procedure is strictly respected, and could remain so for new programming languages.

In other words, the absolute value of the difference between any two implementations does not exceed 1e-10.

### Numerical Stability in CIEDE2000

#### Angle Conversions

The professional approach in software is to use radians for mathematical calculations, because angle conversions, while theoretically valid, result in a loss of precision due to rounding errors in floating-point numbers. Here, only radians are used, without conversion, but this can be a source of inconsistencies for an external implementation.

#### IEEE 754 floating-point Limitations

Minor discrepancies can arise between programming languages, for instance, `atan2(-49.2, -34.9)` evaluates to `-2.1877696633888672` in Python and `-2.1877696633888677` in JavaScript, while `-2.187769663388867475...` is correct. So the threshold for an accepted cross-language exact match is set to `1e-10`, linking sufficiency and achievability.

#### Debugging

Rounding L\*a\*b\* components and ΔE 2000 to [4 decimal places](tests#roundings) can be a solution for realistic color comparisons.

### Performance Overview

Runtimes were recorded while calculating 100 million iterations of the color difference formula ΔE 2000.

| Language | Compilation Type | Duration (mm:ss) | Relative to C |
|:--:|:--:|:--:|:--:|
| C | Compiled| 00:45 | 1× (Reference) |
| Rust | Compiled | 00:52 | 1.15× slower |
| Go | Compiled | 00:52 | 1.15× slower |
| LuaJIT | Just-In-Time Compiled | 00:53 | 1.18× slower |
| Java | Just-In-Time Compiled | 00:57 | 1.25× slower |
| Kotlin|  Just-In-Time Compiled | 00:57 | 1.26× slower |
| TypeScript | Just-In-Time Compiled| 01:17 | 1.7× slower |
| JavaScript | Just-In-Time Compiled | 01:18 | 1.73× slower |
| PHP | Interpreted | 03:28 | 4.57× slower |
| Lua | Interpreted | 07:03 | 9.36× slower |
| Ruby | Interpreted | 07:20 | 9.65× slower |
| Perl | Interpreted | 08:20 | 12.44× slower |
| Python | Interpreted | 10:13 | 13.45× slower |

## Contributing

Examples of interesting programming languages ​​to expand the `ciede_2000` function would be :
- Julia
- Dart
- C#
- MATLAB
- R

### Methodology

To ensure consistency across implementations, please follow these guidelines :
1. **Base your implementation** on an existing one, copy-pasting and adapting is encouraged.
2. **Validate correctness** using the generator available at [this link](https://michel-leonard.github.io/ciede2000/samples.html) :
   - Generate some test sequences.
   - Verify that the computed ΔE 2000 values do not deviate by more than **1e-10** from reference values.
3. **Submit a pull request** with your implementation.

To enhance your contribution, consider:
- Writing documentation, as done for other languages.
- Adding advanced tests (refer to the `tests` directory for examples, and replicate the structure for your language).

Your contribution will then be reviewed and placed, like this entire repository, in the public domain.

## The L\*a\*b\* Color Range

- **L\*** nominally ranges from 0 (white) to 100 (black)
- **a\*** is unbounded and commonly clamped to the range of -128 (green) to 127 (red)
- **b\*** is unbounded and commonly clamped to the range of -128 (blue) to 127 (yellow)

## Short URL
Quickly share this GitHub project permanently using [bit.ly/ciede2000](https://bit.ly/ciede2000).
