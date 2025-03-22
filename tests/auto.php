<?php

// Driver for the tests of the CIE ΔE00 Color-Difference formula, must display a log file.

// Each programming language generates a random file "values-XXX.txt" using the "ciede_2000" function.
// Each language then compares its results with those of the others, tolerating a maximum difference of 1e-10.
// In case of cross-language result mismatch, up to 10 error messages may be displayed before the program stops.

$lang = [
  'c'    =>  [ 'C',          '',                   './hokey-pokey'      ],
  'rs'   =>  [ 'Rust',       'cargo run --quiet',  ''                   ],
  'go'   =>  [ 'Go',         'go run',             'hokey-pokey.go'     ],
  'java' =>  [ 'Java',       'java',               'hokeyPokey'         ],
  'kt'   =>  [ 'Kotlin',     'java -jar',          'hokeyPokey.jar'     ],
  'js'   =>  [ 'JavaScript', 'node',               'hokey-pokey.js'     ],
  'lua'  =>  [ 'LuaJIT',     'luajit -O3',         'hokey-pokey.lua'    ],
  'php'  =>  [ 'PHP',        'php',                'hokey-pokey.php'    ],
  'py'   =>  [ 'Python',     'python3',            'hokey-pokey.py'     ],
  'rb'   =>  [ 'Ruby',       'ruby',               'hokey-pokey.rb'     ],
] ;

// Function used to execute the cross-language sub-programs.
function proc($cmd, $print = false){
	$res = '' ;
	$fp = popen("$cmd 2>&1", 'r');
	if ($fp)
		while(!feof($fp)) {
			$s = fread($fp, 2096) ;
			$res .= $s ;
			if ($print)
				echo $s ;
		}
	pclose($fp);
	return trim($res) ;
}

$n_lines = (int)($argv[1] ?? 100000) ;
if ($n_lines < 1 || $n_lines > 100000000)
	die("The first '$n_lines' parameter should be in [1, 100000000]\n");

$n_lang = count($lang) ;
$n_comparisons = $n_lang * $n_lines * ($n_lang - 1) ;

echo 'Test of the CIEDE2000 function involving ', number_format($n_comparisons, 0, '', ',') ," comparisons between $n_lang programming languages :\n" ;
foreach($lang as $id => [ $name ])
	echo " - $name ... $id\n" ;

echo "\n" ;

$t_0 = microtime(true) ;

foreach($lang as $id_1 => [ $name_1, $cmd_1_1, $cmd_1_2 ]) {
	echo "\n\n", str_repeat('-', 30), "\n" ;
	echo str_repeat('-', 10), " [ $id_1 ] ", str_repeat('-', 14 - strlen($id_1)), "\n" ;
	echo str_repeat('-', 30), "\n" ;
	chdir(__DIR__ . "/$id_1") ;
	$t_1 = microtime(true) ;
	// Produces a file containing samples.
	$cmd_out = proc("$cmd_1_1 $cmd_1_2 $n_lines");
	$t_2 = microtime(true) ;
	$cmd_out = preg_replace('#\s*\.{10,}\s*#', ' ' . str_repeat('.', 37 - strlen("$id_1|$name_1|$n_lines")), $cmd_out) ;
	printf(" - $name_1 prepare the CSV file : $cmd_out took %.01fs\n", $t_2 - $t_1);
	//
	$stats = [ ] ;
	$data_path = __DIR__ . "/$id_1/values-$id_1.txt" ;
	$fp = fopen($data_path, 'r') ;
	if ($fp)
		while(!feof($fp))
			foreach(count_chars(fread($fp, 2096), 1) as $i => $n)
				$stats[$i] = ($stats[$i] ?? 0) + $n ;
	fclose($fp);
	foreach($stats as $k => $v)
		$stats[$k] = [chr($k), $v];
	$stats = array_values($stats);
	// Displays the statistics to ensure that the entropy of each dataset is well distributed.
	echo " - $name_1 CSV file character set is ", substr(str_replace('],[','] [', json_encode($stats)), 1, -1), "\n" ;
	//
	foreach($lang as $id_2 => [ $name_2, $cmd_2_1, $cmd_2_2 ])
		if ($id_1 != $id_2) {
			chdir(__DIR__ . "/$id_2");
			$t_1 = microtime(true) ;
			// All languages check their results against the file.
			$cmd_out = proc("$cmd_2_1 $cmd_2_2 $id_1");
			$t_2 = microtime(true) ;
			$cmd_out = preg_replace('#\s*\.{10,}\s*#', ' ' . str_repeat('.', 40 - strlen("$id_1|$id_1|$name_1|$name_2")), $cmd_out) ;
			printf("   - $name_2 test the $name_1 file : $cmd_out took %.01fs\n", $t_2 - $t_1);
		}
	unlink($data_path);
}

$t = round ((microtime(true) - $t_0) / 60.) ;
echo "\nResult: after ", $t ," minute" , $t < 2 ? '' : 's' , ", the $n_lang languages produce the same output with a tolerance of 1e-10.\n" ;

//
// More samples for the CIEDE2000 color difference formula implementation at https://bit.ly/ciede2000-samples
//
// Testing lab(53.803, 100.386, 64.0) vs lab(53.803, 100.386, 64.0) expects ΔE2000 = ΔE00 = 0.0
// Testing lab(22.0, -8.878, 1.206) vs lab(22.0, -8.878, 1.2) expects ΔE2000 = ΔE00 = 0.00496512601708314
// Testing lab(119.2, 123.51, -72.16) vs lab(119.2, 123.51, -72.0563) expects ΔE2000 = ΔE00 = 0.025217145987100394
// Testing lab(125.0, 45.977, -23.77) vs lab(125.0, 45.8, -23.77) expects ΔE2000 = ΔE00 = 0.06191730728173489
// Testing lab(53.815, 108.127, -53.6956) vs lab(53.91, 108.127, -53.6956) expects ΔE2000 = ΔE00 = 0.09153360157420175
// Testing lab(9.672, 74.191, 117.1707) vs lab(10.01, 74.191, 117.1707) expects ΔE2000 = ΔE00 = 0.21142386542141753
// Testing lab(108.623, -118.353, -51.75) vs lab(109.5602, -118.1, -51.75) expects ΔE2000 = ΔE00 = 0.4997242568354039
// Testing lab(35.7, 121.0, -7.4) vs lab(35.8144, 121.0, -9.6787) expects ΔE2000 = ΔE00 = 0.6557154547423042
// Testing lab(1.814, -1.0, 75.8) vs lab(1.814, -1.0, 80.7) expects ΔE2000 = ΔE00 = 1.0842177134145443
// Testing lab(81.95, -56.7, -48.0971) vs lab(81.95, -52.96, -48.0971) expects ΔE2000 = ΔE00 = 1.1651698633159118
// Testing lab(114.91, 41.0, -63.06) vs lab(114.91, 41.0, -60.0) expects ΔE2000 = ΔE00 = 1.3564379399698363
// Testing lab(88.4958, -97.9914, -118.0) vs lab(88.4958, -90.828, -121.0) expects ΔE2000 = ΔE00 = 1.6685817350660168
// Testing lab(37.3013, 55.0, 51.0) vs lab(37.3013, 55.0, 55.6) expects ΔE2000 = ΔE00 = 1.9857959954080104
// Testing lab(123.94, -33.0, -100.566) vs lab(128.0, -29.03, -100.566) expects ΔE2000 = ΔE00 = 2.334519896142015
// Testing lab(37.872, 82.94, 80.6925) vs lab(37.872, 76.0, 80.6925) expects ΔE2000 = ΔE00 = 2.437554153854694
// Testing lab(35.9816, 110.4, 78.9437) vs lab(37.543, 110.4, 86.13) expects ΔE2000 = ΔE00 = 2.699269285985329
// Testing lab(25.77, -42.0, -67.6) vs lab(29.416, -42.0, -72.0) expects ΔE2000 = ΔE00 = 2.935923828535865
// Testing lab(64.0, -99.0035, -7.0) vs lab(64.0, -99.0035, -14.592) expects ΔE2000 = ΔE00 = 3.1379553254782153
// Testing lab(107.81, -3.91, 23.8) vs lab(107.81, -2.289, 30.5) expects ΔE2000 = ΔE00 = 3.5242270802072735
// Testing lab(21.57, 126.7, 75.924) vs lab(25.2657, 126.7, 84.484) expects ΔE2000 = ΔE00 = 3.7776464937823753
// Testing lab(118.402, 2.626, 105.59) vs lab(126.4, 1.3, 105.59) expects ΔE2000 = ΔE00 = 3.896608631035705
// Testing lab(116.677, -95.0998, -93.2) vs lab(125.43, -95.0998, -93.2) expects ΔE2000 = ΔE00 = 4.241415854047871
// Testing lab(27.6571, -62.0, 86.83) vs lab(33.279, -62.0, 84.0) expects ΔE2000 = ΔE00 = 4.428212696798029
// Testing lab(112.0769, -29.0, -102.71) vs lab(121.49, -29.0, -104.0) expects ΔE2000 = ΔE00 = 4.7112966841936865
// Testing lab(85.7, 114.3, -85.645) vs lab(80.1, 106.0131, -70.8665) expects ΔE2000 = ΔE00 = 4.882409915895245
// Testing lab(63.19, -120.0, 71.1331) vs lab(63.1, -107.1, 44.6953) expects ΔE2000 = ΔE00 = 6.059914472790889
// Testing lab(64.5, -64.437, -93.0) vs lab(62.02, -99.4, -107.93) expects ΔE2000 = ΔE00 = 7.06366987877229
// Testing lab(104.992, -88.61, 100.82) vs lab(103.0, -56.9648, 66.0045) expects ΔE2000 = ΔE00 = 7.946541753654507
// Testing lab(94.02, 45.443, -52.26) vs lab(82.8358, 35.0, -50.847) expects ΔE2000 = ΔE00 = 8.468082841928027
// Testing lab(107.97, -99.06, 61.7) vs lab(106.31, -95.27, 28.0) expects ΔE2000 = ΔE00 = 9.784448720644484
// Testing lab(109.436, 91.0, 75.7) vs lab(125.7, 83.296, 88.9) expects ΔE2000 = ΔE00 = 10.482275988631299
// Testing lab(77.8, -23.1, 71.6) vs lab(89.91, -10.4, 89.0) expects ΔE2000 = ΔE00 = 11.968308773616265
// Testing lab(77.1567, -35.0, 97.213) vs lab(61.21, -41.1, 100.39) expects ΔE2000 = ΔE00 = 12.626490522354542
// Testing lab(107.0952, -81.7738, -21.021) vs lab(85.4268, -99.2, -19.6254) expects ΔE2000 = ΔE00 = 13.403353388987528
// Testing lab(116.0, -114.234, 108.0) vs lab(105.3, -61.486, 43.2) expects ΔE2000 = ΔE00 = 15.047985418844888
// Testing lab(72.065, 81.0, 101.696) vs lab(87.091, 44.0, 79.839) expects ΔE2000 = ΔE00 = 15.244208355627304
// Testing lab(73.0, 113.285, 65.82) vs lab(53.4, 123.3197, 69.0) expects ΔE2000 = ΔE00 = 16.588704786031506
// Testing lab(22.0, 100.87, 97.0) vs lab(43.569, 113.5, 121.3956) expects ΔE2000 = ΔE00 = 17.858859663863797
// Testing lab(22.557, -21.05, -102.952) vs lab(30.039, -80.71, -84.1) expects ΔE2000 = ΔE00 = 18.754894912601415
// Testing lab(78.4, 122.1038, 14.9) vs lab(111.425, 125.623, 20.0) expects ΔE2000 = ΔE00 = 19.83204013561585
// Testing lab(14.9, 55.968, 99.1) vs lab(39.979, 89.7115, 125.421) expects ΔE2000 = ΔE00 = 20.66325400976444
// Testing lab(98.0, 98.51, 12.0) vs lab(70.0, 110.0, 42.8935) expects ΔE2000 = ΔE00 = 21.312624402556157
// Testing lab(86.0, 112.0, 37.254) vs lab(91.2881, 88.5, -30.48) expects ΔE2000 = ΔE00 = 22.38466364241274
// Testing lab(100.39, -38.5, 27.0) vs lab(69.8, -29.76, 4.3962) expects ΔE2000 = ΔE00 = 23.2422827586539
// Testing lab(49.1, -50.5963, 86.75) vs lab(42.809, -0.4, 107.86) expects ΔE2000 = ΔE00 = 24.74635826125564
// Testing lab(107.257, 66.0, 111.0) vs lab(69.33, 119.1167, 82.468) expects ΔE2000 = ΔE00 = 34.50530276865605
// Testing lab(80.22, -62.0, 44.0) vs lab(36.0, -101.734, -59.15) expects ΔE2000 = ΔE00 = 58.218252789469155
// Testing lab(100.32, -61.0, -102.008) vs lab(49.6, -74.4265, 121.0) expects ΔE2000 = ΔE00 = 84.99627218449572
// Testing lab(36.8953, 120.684, 24.279) vs lab(117.0, -42.2, -64.5087) expects ΔE2000 = ΔE00 = 113.11777374329631
// Testing lab(60.85, 74.359, 4.0) vs lab(3.77, -114.8, -30.0) expects ΔE2000 = ΔE00 = 125.67067082324792
