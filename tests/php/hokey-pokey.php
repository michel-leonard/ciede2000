<?php 

// This function written in PHP is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// Classic color accuracy can be ensured with this ΔE, ΔE2000 (ΔE00) implementation.
function ciede_2000($L1, $a1, $b1, $L2, $a2, $b2) {
	// Working with the CIEDE2000 color-difference formula.
	// kL, kC, kH are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	$kL = $kC = $kH = 1.;
	$n = (hypot($a1, $b1) + hypot($a2, $b2)) * .5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	$n = 1. + 0.5 * (1. - sqrt($n / ($n + 6103515625.)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	$c_1 = hypot($a1 * $n, $b1);
	$c_2 = hypot($a2 * $n, $b2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	$h_1 = atan2($b1, $a1 * $n);
	$h_2 = atan2($b2, $a2 * $n);
	$h_1 += 2. * M_PI * ($h_1 < 0.);
	$h_2 += 2. * M_PI * ($h_2 < 0.);
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next line handle this issue.
	$h_tmp = ($h_1 + $h_2) * .5 + M_PI * (M_PI < abs($h_1 - $h_2));
	$n = ($c_1 + $c_2) * .5;
	$n = $n * $n * $n * $n * $n * $n * $n;
	$p = (36. * $h_tmp - 55. * M_PI);
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	$r_t = -2.	* sqrt($n / ($n + 6103515625.))
			* sin(M_PI / 3. * exp($p * $p / (-25. * M_PI * M_PI)));
	$n = ($L1 + $L2) * .5;
	$n = ($n - 50.) * ($n - 50.);
	// Lightness
	$l = ($L2 - $L1) / ($kL * (1. + .015 * $n / sqrt(20. + $n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	$t = 1	+ .24 * sin(2. * $h_tmp + M_PI_2)
			+ .32 * sin(3. * $h_tmp + 8. * M_PI / 15.)
			- .17 * sin($h_tmp + M_PI / 3.)
			- .20 * sin(4. * $h_tmp + 3. * M_PI_2 / 10.);
	$n = $c_1 + $c_2;
	$h_tmp = ($h_2 - $h_1) * .5;
	$h_tmp += M_PI * ($h_tmp < -M_PI_2);
	$h_tmp -= M_PI * (M_PI_2 < $h_tmp);
	// Hue
	$h = 2. * sqrt($c_1 * $c_2) * sin($h_tmp) / ($kH * (1. + .0075 * $n * $t));
	// Chroma
	$c = ($c_2 - $c_1) / ($kC * (1 + .0225 * $n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return sqrt($l * $l + $h * $h + $c * $c + $c * $h * $r_t);
}

function prepare_values($n_lines = 10000) {
	$filename = './values-php.txt' ;
	echo "prepare_values('$filename', $n_lines)\n" ;
	$fp = fopen($filename, 'w');
	for($i = 0; $i < $n_lines; ++$i){
		$values = [
			round(100. * (mt_rand() / mt_getrandmax()), mt_rand(0, 2)),
			round(255. * (mt_rand() / mt_getrandmax()) - 128., mt_rand(0, 2)),
			round(255. * (mt_rand() / mt_getrandmax()) - 128., mt_rand(0, 2)),
			round(100. * (mt_rand() / mt_getrandmax()), mt_rand(0, 2)),
			round(255. * (mt_rand() / mt_getrandmax()) - 128., mt_rand(0, 2)),
			round(255. * (mt_rand() / mt_getrandmax()) - 128., mt_rand(0, 2)),
		];
		if ($i % 1000 == 0)
			echo '.' ;
		$values[ ] = ciede_2000(...$values);
		fputcsv($fp, $values);
	}
	fclose($fp);
}

function compare_values($extension = 'php'){
	$i = $n_errors = 0 ;
	$filename = "./../$extension/values-$extension.txt" ;
	echo "compare_values('$filename')\n" ;
	$fp = fopen($filename, 'r');
	while($arr = fgetcsv($fp, 1024, ',')){
		++$i ;
		$arr = array_map('floatval', $arr);
		$delta_e = array_pop($arr) ;
		$res = ciede_2000(...$arr) ;
		$abs_err = abs($delta_e - $res);
		if (!is_finite($delta_e) || !is_finite($res) || 1e-10 < $abs_err) {
			echo json_encode([
				'submited' => $arr,
				'expected' => $delta_e,
				'computed' => $res,
				'abs_err' => $abs_err], JSON_PRETTY_PRINT), "\n" ;
				if (++$n_errors == 10)
					break ;
		} else if($i % 1000 === 0){
			echo '.' ;
			fflush(STDOUT);
		}
	}
	fclose($fp) ;
}

chdir(__DIR__);

if (ctype_alpha($argv[1] ?? '-'))
	compare_values($argv[1]);
else
	prepare_values((int)($argv[1] ?? 10000));
