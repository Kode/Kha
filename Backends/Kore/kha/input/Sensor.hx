package kha.input;

class Sensor {
	private static var accelerometer: Sensor = new Sensor();
	private static var gyroscope: Sensor = new Sensor();
	private var listeners: Array<Float -> Float -> Float -> Void> = new Array();

	public static function get(type: SensorType): Sensor {
		switch (type) {
		case Accelerometer:
			return accelerometer;
		case Gyroscope:
			return gyroscope;
		}
	}

	public function notify(listener: Float -> Float -> Float -> Void): Void {
		listeners.push(listener);
	}

	private function new() {

	}

	public static function _changed(type: Int, x: Float, y: Float, z: Float): Void {
		var sensor = get(type == 0 ? SensorType.Accelerometer : SensorType.Gyroscope);
		for (listener in sensor.listeners) {
			listener(x, y, z);
		}
	}
}
