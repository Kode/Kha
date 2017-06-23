package kha.input;

import kha.network.Controller;

@:allow(kha.SystemImpl)
@:expose
class Keyboard extends Controller {
	public static function get(num: Int = 0): Keyboard {
		return SystemImpl.getKeyboard(num);
	}
	
	public function notify(downListener: KeyCode->Void, upListener: KeyCode->Void, pressListener: String->Void = null): Void {
		if (downListener != null) downListeners.push(downListener);
		if (upListener != null) upListeners.push(upListener);
		if (pressListener != null) pressListeners.push(pressListener);
	}
	
	public function remove(downListener: KeyCode->Void, upListener: KeyCode->Void, pressListener: String->Void): Void {
		if (downListener != null) downListeners.remove(downListener);
		if (upListener != null) upListeners.remove(upListener);
		if (pressListener != null) pressListeners.remove(pressListener);
	}
	
	public function show(): Void {

	}

	public function hide(): Void {

	}

	private static var instance: Keyboard;
	private var downListeners: Array<KeyCode->Void>;
	private var upListeners: Array<KeyCode->Void>;
	private var pressListeners: Array<String->Void>;
	
	private function new() {
		super();
		downListeners = [];
		upListeners = [];
		pressListeners = [];
		instance = this;
	}
	
	@input
	private function sendDownEvent(code: KeyCode): Void {
		#if sys_server
		//js.Node.console.log(kha.Scheduler.time() + " Down: " + key + " from " + kha.network.Session.the().me.id);
		#end
		for (listener in downListeners) {
			listener(code);
		}
	}
	
	@input
	private function sendUpEvent(code: KeyCode): Void {
		#if sys_server
		//js.Node.console.log(kha.Scheduler.time() + " Up: " + key + " from " + kha.network.Session.the().me.id);
		#end
		for (listener in upListeners) {
			listener(code);
		}
	}

	@input
	private function sendPressEvent(char: String): Void {
		for (listener in pressListeners) {
			listener(char);
		}
	}
}
