package kha.input;

@:allow(kha.SystemImpl)
@:expose
class Gamepad {
	var index: Int;

	public static function get(index: Int = 0): Null<Gamepad> {
		if (index >= instances.length)
			return null;
		return instances[index];
	}

	/**
		Use this event to get connected gamepad `index` and listen to it with `Gamepad.get(index).notify(axisListener, buttonListener)`.

		Remember to also check `Gamepad.get(0)`, gamepads may already be connected before the application was initialized.
	**/
	public static function notifyOnConnect(?connectListener: (index: Int) -> Void, ?disconnectListener: (index: Int) -> Void): Void {
		if (connectListener != null)
			connectListeners.push(connectListener);
		if (disconnectListener != null)
			disconnectListeners.push(disconnectListener);
	}

	public static function removeConnect(?connectListener: (index: Int) -> Void, ?disconnectListener: (index: Int) -> Void): Void {
		if (connectListener != null)
			connectListeners.remove(connectListener);
		if (disconnectListener != null)
			disconnectListeners.remove(disconnectListener);
	}

	/**
		In `axisListener`, `axisId` is axis id (for example `axis == 0` is L-stick `x`, `1` is L-stick `y`, `2` is R-stick `x`, `3` is R-stick `y`, ...) and `value` is in `-1.0 - 1.0` range.

		In `buttonListener`, `buttonId` is pressed button id (layout depends on `vendor`), and `value` is in `0 - 1.0` range how hard the button is pressed.
	**/
	public function notify(?axisListener: (axisId: Int, value: Float) -> Void, ?buttonListener: (buttonId: Int, value: Float) -> Void): Void {
		if (axisListener != null)
			axisListeners.push(axisListener);
		if (buttonListener != null)
			buttonListeners.push(buttonListener);
	}

	public function remove(?axisListener: (axisId: Int, value: Float) -> Void, ?buttonListener: (buttonId: Int, value: Float) -> Void): Void {
		if (axisListener != null)
			axisListeners.remove(axisListener);
		if (buttonListener != null)
			buttonListeners.remove(buttonListener);
	}

	static var instances: Array<Gamepad> = [];

	var axisListeners: Array<(axisId: Int, value: Float) -> Void> = [];
	var buttonListeners: Array<(buttonId: Int, value: Float) -> Void> = [];

	static var connectListeners: Array<(index: Int) -> Void> = [];
	static var disconnectListeners: Array<(index: Int) -> Void> = [];

	function new(index: Int = 0, id: String = "unknown") {
		connected = false;
		this.index = index;
		instances[index] = this;
	}

	public var id(get, null): String;
	public var vendor(get, null): String;
	public var connected(default, null): Bool;

	public function rumble(leftAmount: Float, rightAmount: Float) {
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
