package kha.input;

@:allow(kha.SystemImpl)
@:expose
class Gamepad {
	private var index: Int;

	public static function get(index: Int = 0): Gamepad {
		if (index >= instances.length) return null;
		return instances[index];
	}

	public static function notifyOnConnect(connectListener: Int->Void, disconnectListener: Int->Void): Void {
		if (connectListener != null) connectListeners.push(connectListener);
		if (disconnectListener != null) disconnectListeners.push(disconnectListener);
	}

	public static function removeConnect(connectListener: Int->Void, disconnectListener: Int->Void): Void {
		if (connectListener != null) connectListeners.remove(connectListener);
		if (disconnectListener != null) disconnectListeners.remove(disconnectListener);
	}

	public function notify(axisListener: Int->Float->Void, buttonListener: Int->Float->Void): Void {
		if (axisListener != null) axisListeners.push(axisListener);
		if (buttonListener != null) buttonListeners.push(buttonListener);
	}
	
	public function remove(axisListener: Int->Float->Void, buttonListener: Int->Float->Void): Void {
		if (axisListener != null) axisListeners.remove(axisListener);
		if (buttonListener != null) buttonListeners.remove(buttonListener);
	}
	
	private static var instances: Array<Gamepad> = new Array();
	private var axisListeners: Array<Int->Float->Void>;
	private var buttonListeners: Array<Int->Float->Void>;
	private static var connectListeners:Array<Int->Void> = new Array();
	private static var disconnectListeners:Array<Int->Void> = new Array();
	
	private function new(index: Int = 0, id: String = "unknown") {
		this.index = index;
		axisListeners = new Array<Int->Float->Void>();
		buttonListeners = new Array<Int->Float->Void>();
		instances[index] = this;
	}

	public var id(get, null): String;
	public var connected(default, null):Bool;

	private function get_id(): String {
		return SystemImpl.getGamepadId(index);
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
	
	@input
	private static function sendConnectEvent(index: Int): Void {
		instances[index].connected = true;
		for (listener in connectListeners) {
			listener(index);
		}
	}
	
	@input
	private static function sendDisconnectEvent(index: Int): Void {
		instances[index].connected = false;
		for (listener in disconnectListeners) {
			listener(index);
		}
	}
}
