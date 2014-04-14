package kha.scene;

import kha.math.Vector3;

class Spline {
	private static function deBoor4(k: Int, degree: Int, i: Int, x: Float, knots: Array<Float>, ctrlPoints: Array<Vector3>): Vector3 {
		if (k == 0) return ctrlPoints[i];
		else {
			var alpha = (x - knots[i]) / (knots[i + degree + 1 - k] - knots[i]);
			return deBoor4(k - 1, degree, i - 1, x, knots, ctrlPoints).mult(1 - alpha).add(deBoor4(k - 1, degree, i, x, knots, ctrlPoints).mult(alpha));
		}
	}

	private static function findInterval(x: Float, knots: Array<Float>): Int {
		for (i in 1...knots.length) {
			if (x < knots[i]) return i - 1;
			else if (x == knots[knots.length - 1]) return knots.length - 1;
		}
		return -1;
	}

	private static function deBoor3(degree: Int, x: Float, knots: Array<Float>, ctrlPoints: Array<Vector3>): Vector3 {
		return deBoor4(degree, degree, findInterval(x, knots), x, knots, ctrlPoints);
	}
	
	public static function deBoor2(ctrlPoints: Array<Vector3>, x: Float, degree: Int): Vector3 {
		var knots = new Array<Float>();
		knots[ctrlPoints.length + degree] = 0;
		for (i in 0...degree + 1) knots[i] = 0;
		for (i in knots.length - degree - 2...ctrlPoints.length + degree + 1) knots[i] = 1.01;
		var count: Int = knots.length - (degree + 1) * 2 + 1;
		for (i in degree + 1...knots.length - degree - 1) {
			knots[i] = 1.0 * (i - degree) / count;
		}
		return deBoor3(degree, x, knots, ctrlPoints);
	}

	public static function deBoor(ctrlPoints: Array<Vector3>, x: Float): Vector3 {
		return deBoor2(ctrlPoints, x, 3);
	}

	public static function deCasteljau(P: Array<Vector3>, u: Float): Vector3 {
		var Q = new Array<Vector3>();
		//Q.resize(P.size());
		for (i in 0...P.length) Q.push(P[i]);
		for (k in 1...P.length) {
			for (i in 0...P.length - k) {
				Q[i] = Q[i].mult(1 - u).add(Q[i + 1].mult(u));
			}
		}
		return Q[0];
	}

	private var stepLength: Float = 0.0001;
	private var splineLength: Float;
	private var lengthSteps: Array<Float>; //[10001];
	private var posSteps: Array<Vector3>; //[10001];

	private function calculateSplineLength(points: Array<Vector3>, func: Array<Vector3> -> Float -> Vector3): Float {
		var length: Float = 0;
		lengthSteps[0] = 0;
		var last = func(points, 0);
		posSteps[0] = last;
		for (i in 1...10000) {
			var position = stepLength * i;
			var current = func(points, position);
			length += current.sub(last).length;
			lengthSteps[i] = length;
			posSteps[i] = current;
			last = current;
		}
		length += func(points, 1.0).sub(last).length;
		lengthSteps[10000] = length;
		posSteps[10000] = func(points, 1.0);
		return length;
	}

	public function constantSpeedSpline(t: Float): Vector3 {
		return constantSpeedSplineDistance(t * splineLength);
	}

	public function constantSpeedSplineDistance(aim: Float): Vector3 {
		if (aim >= lengthSteps[10000]) return posSteps[10000];

		var i: Int = 0;
		
		while (lengthSteps[i] < aim) ++i;

		if (i == 0) return posSteps[0];

		var length: Float = lengthSteps[i];
		var prevLength: Float = lengthSteps[i - 1];
		
		var current = posSteps[i];
		var last = posSteps[i - 1];

		var dif = current.sub(last);
		var toNextLength = length - prevLength;
		var toAim = aim - prevLength;
		return last.add(dif.mult(toAim / toNextLength));
	}

	public function new(points: Array<Vector3>, func: Array<Vector3> -> Float -> Vector3) {
		lengthSteps = new Array<Float>();
		posSteps = new Array<Vector3>();
		splineLength = calculateSplineLength(points, func);
	}
}
