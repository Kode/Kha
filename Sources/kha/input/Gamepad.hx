package kha.input;

@:allow(kha.SystemImpl)
@:expose
class Gamepad {
	private var index: Int;

	public static function get(index: Int = 0): Gamepad {
		if (index >= instances.length) return null;
		return instances[index];
	}
	public static function notifyConnect(connectListener:Int->Void): Void {
		if(connectListener!=null)connectListeners.push(connectListener);
	}
	public static function removeConnect(connectListener:Int->Void): Void {
		if(connectListener!=null)connectListeners.remove(connectListener);
	}

	public function notify(axisListener: Int->Float->Void, buttonListener: Int->Float->Void,disconnectListener:Gamepad->Void): Void {
		if (axisListener != null) axisListeners.push(axisListener);
		if (buttonListener != null) buttonListeners.push(buttonListener);
		if (disconnectListener != null) disconnectListeners.push(disconnectListener);
	}
	
	public function remove(axisListener: Int->Float->Void, buttonListener: Int->Float->Void,disconnectListener:Gamepad->Void): Void {
		if (axisListener != null) axisListeners.remove(axisListener);
		if (buttonListener != null) buttonListeners.remove(buttonListener);
		if (disconnectListener != null) disconnectListeners.remove(disconnectListener);
	}
	
	private static var instances: Array<Gamepad> = new Array<Gamepad>();
	private var axisListeners: Array<Int->Float->Void>;
	private var buttonListeners: Array<Int->Float->Void>;
	private static var connectListeners:Array<Int->Void> =new Array<Int->Void>();
	private var disconnectListeners:Array<Gamepad->Void>;
	
	private function new(index: Int = 0, id: String = "unknown") {
		this.index = index;
		axisListeners = new Array<Int->Float->Void>();
		buttonListeners = new Array<Int->Float->Void>();
		disconnectListeners = new Array<Gamepad->Void>();
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
	private static function sendConnectEvent(index:Int): Void {
		instances[index].connected = true;
		for (listener in connectListeners) {
			listener(index);
		}
	}
	
	@input
	private function sendDisconnectEvent(): Void {
		connected = false;
		for (listener in disconnectListeners) {
			listener(this);
		}
	}
}
