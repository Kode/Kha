package kha.input;

import kha.SystemImpl;

class Sensor {
	static var isInited: Bool = false;
	static var accelerometer: Sensor = new Sensor();
	static var gyroscope: Sensor = new Sensor();

	var listeners: Array<Float->Float->Float->Void> = new Array();

	public static function get(type: SensorType): Sensor {
		switch (type) {
			case Accelerometer:
				return accelerometer;
			case Gyroscope:
				return gyroscope;
		}
	}

	public function notify(listener: Float->Float->Float->Void): Void {
		if (!isInited) {
			SystemImpl.initSensor();
			isInited = true;
		}
		listeners.push(listener);
	}

	function new() {}

	public static function _changed(type: Int, x: Float, y: Float, z: Float): Void {
		var sensor = get(type == 0 ? SensorType.Accelerometer : SensorType.Gyroscope);
		for (listener in sensor.listeners) {
			listener(x, y, z);
		}
	}
}
