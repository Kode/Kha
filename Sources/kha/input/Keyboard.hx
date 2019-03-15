package kha.input;

import kha.netsync.Controller;

@:allow(kha.SystemImpl)
@:expose
class Keyboard extends Controller {
	/**
	 * Get current Keyboard.
	 * @param num (optional) keyboard id (0 by default).
	 */
	public static function get(num: Int = 0): Keyboard {
		return SystemImpl.getKeyboard(num);
	}
	
	/**
	 * Creates event handlers from passed functions.
	 * @param downListener function with `key:KeyCode` argument, fired when a key is pressed down.
	 * @param upListener function with `key:KeyCode` argument, fired when a key is released.
	 * @param pressListener (optional) function with `char:String` argument, fired when a key that produces a character value is pressed down.
	 */
	public function notify(downListener: KeyCode->Void, upListener: KeyCode->Void, pressListener: String->Void = null): Void {
		if (downListener != null) downListeners.push(downListener);
		if (upListener != null) upListeners.push(upListener);
		if (pressListener != null) pressListeners.push(pressListener);
	}
	
	/**
	 * Removes event handlers from the passed functions that were passed to `notify` function.
	 */
	public function remove(downListener: KeyCode->Void, upListener: KeyCode->Void, pressListener: String->Void): Void {
		if (downListener != null) downListeners.remove(downListener);
		if (upListener != null) upListeners.remove(upListener);
		if (pressListener != null) pressListeners.remove(pressListener);
	}
	
	/**
	 * Show virtual keyboard (if it exists).
	 */
	public function show(): Void {

	}

	/**
	 * Hide virtual keyboard (if it exists).
	 */
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
