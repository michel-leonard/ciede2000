import * as fs from 'fs';
import * as readline from 'readline';

// npm init -y; npm install --save-dev @types/node; tsc --init; tsc hokey-pokey.ts

// This function written in TypeScript is not affiliated with the CIE (International Commission on Illumination),
// and is released into the public domain. It is provided "as is" without any warranty, express or implied.

// The classic CIE ΔE implementation, ΔE2000 (ΔE00).
function ciede_2000(l_1: number, a_1: number, b_1: number, l_2: number, a_2: number, b_2: number): number {
	// Working with the CIEDE2000 color-difference formula.
	// k_l, k_c, k_h are parametric factors to be adjusted according to
	// different viewing parameters such as textures, backgrounds...
	const k_l = 1.0, k_c = 1.0, k_h = 1.0;
	let n = (Math.hypot(a_1, b_1) + Math.hypot(a_2, b_2)) * 0.5;
	n = n * n * n * n * n * n * n;
	// A factor involving chroma raised to the power of 7 designed to make
	// the influence of chroma on the total color difference more accurate.
	n = 1.0 + 0.5 * (1.0 - Math.sqrt(n / (n + 6103515625.0)));
	// hypot calculates the Euclidean distance while avoiding overflow/underflow.
	const c_1 = Math.hypot(a_1 * n, b_1), c_2 = Math.hypot(a_2 * n, b_2);
	// atan2 is preferred over atan because it accurately computes the angle of
	// a point (x, y) in all quadrants, handling the signs of both coordinates.
	let h_1 = Math.atan2(b_1, a_1 * n), h_2 = Math.atan2(b_2, a_2 * n);
	if (h_1 < 0.0)
		h_1 += 2.0 * Math.PI;
	if (h_2 < 0.0)
		h_2 += 2.0 * Math.PI;
	n = Math.abs(h_2 - h_1);
	// Cross-implementation consistent rounding.
	if (Math.PI - 1E-14 < n && n < Math.PI + 1E-14)
		n = Math.PI;
	// When the hue angles lie in different quadrants, the straightforward
	// average can produce a mean that incorrectly suggests a hue angle in
	// the wrong quadrant, the next lines handle this issue.
	let h_m = 0.5 * h_1 + 0.5 * h_2, h_d = (h_2 - h_1) * 0.5;
	if (Math.PI < n) {
		if (0.0 < h_d)
			h_d -= Math.PI;
		else
			h_d += Math.PI;
		h_m += Math.PI;
	}
	const p = (36.0 * h_m - 55.0 * Math.PI);
	n = (c_1 + c_2) * 0.5;
	n = n * n * n * n * n * n * n;
	// The hue rotation correction term is designed to account for the
	// non-linear behavior of hue differences in the blue region.
	const r_t = -2.0 * Math.sqrt(n / (n + 6103515625.0))
		* Math.sin(Math.PI / 3.0 * Math.exp(p * p / (-25.0 * Math.PI * Math.PI)));
	n = (l_1 + l_2) * 0.5;
	n = (n - 50.0) * (n - 50.0);
	// Lightness.
	const l = (l_2 - l_1) / (k_l * (1.0 + 0.015 * n / Math.sqrt(20.0 + n)));
	// These coefficients adjust the impact of different harmonic
	// components on the hue difference calculation.
	const t = 1.0 + 0.24 * Math.sin(2.0 * h_m + Math.PI / 2.0)
			+ 0.32 * Math.sin(3.0 * h_m + 8.0 * Math.PI / 15.0)
			- 0.17 * Math.sin(h_m + Math.PI / 3.0)
			- 0.20 * Math.sin(4.0 * h_m + 3.0 * Math.PI / 20.0);
	n = c_1 + c_2;
	// Hue.
	const h = 2.0 * Math.sqrt(c_1 * c_2) * Math.sin(h_d) / (k_h * (1.0 + 0.0075 * n * t));
	// Chroma.
	const c = (c_2 - c_1) / (k_c * (1.0 + 0.0225 * n));
	// Returning the square root ensures that the result represents
	// the "true" geometric distance in the color space.
	return Math.sqrt(l * l + h * h + c * c + c * h * r_t);
}

// GitHub Project : https://github.com/michel-leonard/ciede2000
//  More Examples : https://michel-leonard.github.io/ciede2000/samples.html

// L1 = 22.7           a1 = 3.0            b1 = 70.6
// L2 = 22.7039        a2 = 3.0            b2 = 70.6
// CIE ΔE2000 = ΔE00 = 0.00277761151

// L1 = 99.0           a1 = 110.19         b1 = -79.32
// L2 = 99.0           a2 = 110.19         b2 = -79.0
// CIE ΔE2000 = ΔE00 = 0.0837805098

// L1 = 13.95          a1 = -37.86         b1 = 61.0
// L2 = 16.453         a2 = -37.86         b2 = 61.0
// CIE ΔE2000 = ΔE00 = 1.64918469397

// L1 = 48.803         a1 = 79.215         b1 = 45.1772
// L2 = 48.803         a2 = 87.494         b2 = 45.1772
// CIE ΔE2000 = ΔE00 = 2.2806377728

// L1 = 74.535         a1 = 47.759         b1 = -11.12
// L2 = 74.535         a2 = 39.5           b2 = -11.12
// CIE ΔE2000 = ΔE00 = 2.84267717405

// L1 = 17.7476        a1 = 38.0           b1 = 118.9681
// L2 = 24.1           a2 = 39.7716        b2 = 124.0
// CIE ΔE2000 = ΔE00 = 4.50944190844

// L1 = 98.0           a1 = -34.7          b1 = 56.4242
// L2 = 94.17          a2 = -69.0          b2 = 96.3
// CIE ΔE2000 = ΔE00 = 10.65220908947

// L1 = 86.65          a1 = 38.1583        b1 = 21.8
// L2 = 78.17          a2 = 125.68         b2 = 79.36
// CIE ΔE2000 = ΔE00 = 20.51516866102

// L1 = 52.0           a1 = -120.058       b1 = 4.83
// L2 = 39.0           a2 = -69.0          b2 = -30.1
// CIE ΔE2000 = ΔE00 = 23.28301099722

// L1 = 94.0           a1 = -110.3454      b1 = 17.6
// L2 = 98.964         a2 = -85.0          b2 = 100.83
// CIE ΔE2000 = ΔE00 = 24.56233884272

function compare_values(ext: string): void {
	const path = `./../${ext}/values-${ext}.txt`;
	process.stdout.write(`compare_values('${path}')\n`);

	const rl = readline.createInterface({
		input: fs.createReadStream(path),
		terminal: false,
	});

	let n_err = 0, n = 0;

	rl.on('line', (line: string) => {
		const row: number[] = line.split(',').map(parseFloat);
		const delta_E = row.pop() as number; // 'as number' car on sait que ce n'est pas undefined ici
		const res = ciede_2000(row[0], row[1], row[2], row[3], row[4], row[5]);
		const err = Math.abs(res - delta_E);

		if (!isFinite(res) || !isFinite(delta_E) || 1e-10 < err) {
			process.stdout.write(`Error with ${line} get ${res}`);
			if (++n_err === 10) rl.close();
		} else if (++n % 1000 === 0) {
			process.stdout.write('.');
		}
	});
}

function prepare_values(num: number = 10000): void {
	const path = './values-ts.txt';
	process.stdout.write(`prepare_values('${path}', ${num})\n`);
	const stream = fs.createWriteStream(path, { flags: 'w' });

	stream.once('open', async () => {
		for (let i = 0; i < num; ++i) {
			const row: number[] = [
				parseFloat((Math.random() * 100).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 100).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
				parseFloat((Math.random() * 256 - 128).toFixed(3 * Math.random())),
			];

			if (i % 1000 === 0) {
				process.stdout.write('.');
			}

			row.push(ciede_2000(row[0], row[1], row[2], row[3], row[4], row[5]));

			if (!stream.write(row.join(',') + '\n')) {
				await new Promise<void>((resolve) => stream.once('drain', resolve));
			}
		}
	});
}

const arg = process.argv.pop()?.toLowerCase();
if (arg && /^[a-z]+$/.test(arg)) {
	compare_values(arg);
} else {
	prepare_values((~~Number(arg)) || 10000);
}
