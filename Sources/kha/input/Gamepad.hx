package kha.input;

@:allow(kha.SystemImpl)
@:expose
class Gamepad {	
	public static function get(num: Int = 0): Gamepad {
		if (num >= instances.length) return null;
		return instances[num];
	}

	public function notify(axisListener: Int->Float->Void, buttonListener: Int->Float->Void): Void {
		if (axisListener != null) axisListeners.push(axisListener);
		if (buttonListener != null) buttonListeners.push(buttonListener);
	}
	
	public function remove(axisListener: Int->Float->Void, buttonListener: Int->Float->Void): Void {
		if (axisListener != null) axisListeners.remove(axisListener);
		if (buttonListener != null) buttonListeners.remove(buttonListener);
	}
	
	private static var instances: Array<Gamepad> = new Array<Gamepad>();
	private var axisListeners: Array<Int->Float->Void>;
	private var buttonListeners: Array<Int->Float->Void>;
	
	private function new(id : Int = 0) {
		axisListeners = new Array<Int->Float->Void>();
		buttonListeners = new Array<Int->Float->Void>();
		instances[id] = this;
	}
	
	@input
	private function sendAxisEvent(axis: Int, value: Float): Void {
		for (listener in axisListeners) {
			listener(axis, value);
		}
	}
	
	@input
	private function sendButtonEvent(button: Int, value: Float): Void {
		for (listener in buttonListeners) {
			listener(button, value);
		}
	}
}
