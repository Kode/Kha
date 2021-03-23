package kha.input;

@:allow(kha.SystemImpl)
@:expose
class Gamepad {
	var index: Int;

	public static function get(index: Int = 0): Gamepad {
		if (index >= instances.length)
			return null;
		return instances[index];
	}

	public static function notifyOnConnect(?connectListener: Int->Void, ?disconnectListener: Int->Void): Void {
		if (connectListener != null)
			connectListeners.push(connectListener);
		if (disconnectListener != null)
			disconnectListeners.push(disconnectListener);
	}

	public static function removeConnect(?connectListener: Int->Void, ?disconnectListener: Int->Void): Void {
		if (connectListener != null)
			connectListeners.remove(connectListener);
		if (disconnectListener != null)
			disconnectListeners.remove(disconnectListener);
	}

	public function notify(?axisListener: Int->Float->Void, ?buttonListener: Int->Float->Void): Void {
		if (axisListener != null)
			axisListeners.push(axisListener);
		if (buttonListener != null)
			buttonListeners.push(buttonListener);
	}

	public function remove(?axisListener: Int->Float->Void, ?buttonListener: Int->Float->Void): Void {
		if (axisListener != null)
			axisListeners.remove(axisListener);
		if (buttonListener != null)
			buttonListeners.remove(buttonListener);
	}

	static var instances: Array<Gamepad> = new Array();

	var axisListeners: Array<Int->Float->Void>;
	var buttonListeners: Array<Int->Float->Void>;

	static var connectListeners: Array<Int->Void> = new Array();
	static var disconnectListeners: Array<Int->Void> = new Array();

	function new(index: Int = 0, id: String = "unknown") {
		connected = false;
		this.index = index;
		axisListeners = new Array<Int->Float->Void>();
		buttonListeners = new Array<Int->Float->Void>();
		instances[index] = this;
	}

	public var id(get, null): String;
	public var vendor(get, null): String;
	public var connected(default, null): Bool;

	public function rumble(leftAmount:Float, rightAmount:Float) {
		SystemImpl.setGamepadRumble(index, leftAmount, rightAmount);
	}
	
	function get_id(): String {
		return SystemImpl.getGamepadId(index);
	}

	function get_vendor(): String {
		return SystemImpl.getGamepadVendor(index);
	}

	@input
	function sendAxisEvent(axis: Int, value: Float): Void {
		for (listener in axisListeners) {
			listener(axis, value);
		}
	}

	@input
	function sendButtonEvent(button: Int, value: Float): Void {
		for (listener in buttonListeners) {
			listener(button, value);
		}
	}

	@input
	static function sendConnectEvent(index: Int): Void {
		instances[index].connected = true;
		for (listener in connectListeners) {
			listener(index);
		}
	}

	@input
	static function sendDisconnectEvent(index: Int): Void {
		instances[index].connected = false;
		for (listener in disconnectListeners) {
			listener(index);
		}
	}
}
