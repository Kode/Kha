package kha.input;

#if cpp

extern class Sensor {
	public static function get(type: SensorType): Sensor;

	public function notify(listener: Float -> Float -> Float -> Void): Void;
}

#else

class Sensor {
	public static function get(type: SensorType): Sensor {
		return null;
	}

	public function notify(listener: Float -> Float -> Float -> Void): Void {

	}
}

#end
