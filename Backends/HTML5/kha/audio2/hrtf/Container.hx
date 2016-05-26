package kha.audio2.hrtf;

import js.html.Float32Array;
import kha.Blob;

// based on https://github.com/tmwoz/hrtf-panner-js
class Container {
	var hrir: Dynamic = {};
	
	var triangulation = {
		points: [],
		triangles: []
	};
	
	public function new() {
		
	}

	public function loadHrir(file: Blob) {
		var rawData = new Float32Array(file.bytes.getData());
		var ir: Dynamic = {};
		ir.L = {};
		ir.R = {};
		var azimuths: Dynamic = [-90, -80, -65, -55, -45, -40, -35, -30, -25, -20,
			-15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 55, 65, 80, 90];
		var points: Dynamic = [];

		var hrirLength = 200;
		var k = 0;
		for (i in 0...azimuths.length) {
			var azi: Dynamic = azimuths[i];
			ir.L[azi] = {};
			ir.R[azi] = {};

			// -90 deg elevation
			ir.L[azi][-90] = rawData.subarray(k, k + hrirLength);
			k += hrirLength;
			ir.R[azi][-90] = rawData.subarray(k, k + hrirLength);
			k += hrirLength;

			points.push([azi, -90]);
			// 50 elevations: -45 + 5.625 * (0:49)
			for (j in 0...50) {
				var elv: Dynamic = -45 + 5.625 * j;
				ir.L[azi][elv] = rawData.subarray(k, k + hrirLength);
				k += hrirLength;
				ir.R[azi][elv] = rawData.subarray(k, k + hrirLength);
				k += hrirLength;
				points.push([azi, elv]);
			}

			// 270 deg elevation
			ir.L[azi][270] = rawData.subarray(k, k + hrirLength);
			k += hrirLength;
			ir.R[azi][270] = rawData.subarray(k, k + hrirLength);
			k += hrirLength;
			points.push([azi, 270]);
		}

		hrir = ir;
		triangulation.triangles = Delaunay.triangulate(points);
		triangulation.points = points;
	}

	public function interpolateHRIR(azm: Dynamic, elv: Dynamic): Dynamic {
		var triangles: Dynamic = triangulation.triangles;
		var points: Dynamic = triangulation.points;
		var i: Dynamic = triangles.length - 1;
		var A: Dynamic, B: Dynamic, C: Dynamic, X: Dynamic, T: Dynamic, invT: Dynamic, det: Dynamic, g1: Dynamic, g2: Dynamic, g3: Dynamic;
		while (true) {
			A = points[triangles[i]]; i--;
			B = points[triangles[i]]; i--;
			C = points[triangles[i]]; i--;
			T = [A[0] - C[0], A[1] - C[1],
				 B[0] - C[0], B[1] - C[1]];
			invT = [T[3], -T[1], -T[2], T[0]];
			det = 1 / (T[0] * T[3] - T[1] * T[2]);
			for (j in 0...invT.length)
				invT[j] *= det;
			X = [azm - C[0], elv - C[1]];
			g1 = invT[0] * X[0] + invT[2] * X[1];
			g2 = invT[1] * X[0] + invT[3] * X[1];
			g3 = 1 - g1 - g2;
			if (g1 >= 0 && g2 >= 0 && g3 >= 0) {
				var hrirL = new Float32Array(200);
				var hrirR = new Float32Array(200);
				for (i in 0...200) {
					hrirL[i] = g1 * hrir.L[A[0]][A[1]][i] +
						g2 * hrir.L[B[0]][B[1]][i] +
						g3 * hrir.L[C[0]][C[1]][i];
					hrirR[i] = g1 * hrir.R[A[0]][A[1]][i] +
						g2 * hrir.R[B[0]][B[1]][i] +
						g3 * hrir.R[C[0]][C[1]][i];
				}
				return [hrirL, hrirR];
			}
			else if (i < 0) {
				break;
			}
		}
		return [new Float32Array(200), new Float32Array(200)];
	}
}
