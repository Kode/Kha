package kha.input;

import kha.netsync.Controller;

/** See `Keyboard.disableSystemInterventions` */
enum BlockInterventions {
	Default;
	Full;
	None;
	Custom(func: (code: KeyCode) -> Bool);
}

@:allow(kha.SystemImpl)
@:expose
class Keyboard extends Controller {
	static var keyBehavior = BlockInterventions.Default;

	/**
	 * Get current Keyboard.
	 * @param num (optional) keyboard id (0 by default).
	 */
	public static function get(num: Int = 0): Keyboard {
		return SystemImpl.getKeyboard(num);
	}

	/**
	 * Disables system hotkeys (html5 only).
	 * @param behavior can be:
	 *   Default - allow F-keys and char keys.
	 *   Full - disable all keys (that browser allows).
	 *   None - do not block any key.
	 *   Custom(func:(code:Int)->Bool) - set custom handler for keydown event (should return true if keycode blocked).
	 */
	public static function disableSystemInterventions(behavior: BlockInterventions): Void {
		keyBehavior = behavior;
	}

	/**
	 * Creates event handlers from passed functions.
	 * @param downListener (optional) function with `key:KeyCode` argument, fired when a key is pressed down.
	 * @param upListener (optional) function with `key:KeyCode` argument, fired when a key is released.
	 * @param pressListener (optional) function with `char:String` argument, fired when a key that produces a character value is pressed down.
	 */
	public function notify(?downListener: (key: KeyCode) -> Void, ?upListener: (key: KeyCode) -> Void, ?pressListener: (char: String) -> Void = null): Void {
		if (downListener != null)
			downListeners.push(downListener);
		if (upListener != null)
			upListeners.push(upListener);
		if (pressListener != null)
			pressListeners.push(pressListener);
	}

	/**
	 * Removes event handlers from the passed functions that were passed to `notify` function.
	 */
	public function remove(?downListener: (key: KeyCode) -> Void, ?upListener: (key: KeyCode) -> Void, ?pressListener: (char: String) -> Void): Void {
		if (downListener != null)
			downListeners.remove(downListener);
		if (upListener != null)
			upListeners.remove(upListener);
		if (pressListener != null)
			pressListeners.remove(pressListener);
	}

	/**
	 * Show virtual keyboard (if it exists).
	 */
	public function show(): Void {}

	/**
	 * Hide virtual keyboard (if it exists).
	 */
	public function hide(): Void {}

	static var instance: Keyboard;

	var downListeners: Array<(key: KeyCode) -> Void>;
	var upListeners: Array<(key: KeyCode) -> Void>;
	var pressListeners: Array<(char: String) -> Void>;

	function new() {
		super();
		downListeners = [];
		upListeners = [];
		pressListeners = [];
		instance = this;
	}

	@input
	function sendDownEvent(code: KeyCode): Void {
		#if sys_server
		// js.Node.console.log(kha.Scheduler.time() + " Down: " + key + " from " + kha.network.Session.the().me.id);
		#end
		for (listener in downListeners) {
			listener(code);
		}
	}

	@input
	function sendUpEvent(code: KeyCode): Void {
		#if sys_server
		// js.Node.console.log(kha.Scheduler.time() + " Up: " + key + " from " + kha.network.Session.the().me.id);
		#end
		for (listener in upListeners) {
			listener(code);
		}
	}

	@input
	function sendPressEvent(char: String): Void {
		for (listener in pressListeners) {
			listener(char);
		}
	}
}
