package kha.audio2.hrtf;

class Utils {
	public static function cartesianToInteraural(x1: Float, x2: Float, x3: Float) {
		var r = Math.sqrt(x1 * x1 + x2 * x2 + x3 * x3);
		var azm = rad2deg(Math.asin(x1 / r));
		var elv = rad2deg(Math.atan2(x3, x2));
		if (x2 < 0 && x3 < 0)
			elv += 360;
		return { r: r, azm: azm, elv: elv };
	}

	public static function interauralToCartesian(r, azm, elv) {
		azm = deg2rad(azm);
		elv = deg2rad(elv);
		var x1 = r * Math.sin(azm);
		var x2 = r * Math.cos(azm) * Math.cos(elv);
		var x3 = r * Math.cos(azm) * Math.sin(elv);
		return { x1: x1, x2: x2, x3: x3 };
	}

	public static function deg2rad(deg: Float) {
		return deg * Math.PI / 180;
	}

	public static function rad2deg(rad: Float) {
		return rad * 180 / Math.PI;
	}
}
