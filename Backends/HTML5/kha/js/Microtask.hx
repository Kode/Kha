package kha.js;

import js.html.MessageChannel;

class Microtask {
	static var messageChannel: MessageChannel;
	static final callbacks: Array<() -> Void> = [];

	static function init(): Void {
		if (messageChannel != null) {
			return;
		}
		messageChannel = new MessageChannel();
		messageChannel.port1.onmessage = _ -> {
			final copy = callbacks.copy();
			callbacks.resize(0);
			for (callback in copy) {
				callback();
			}
		};
	}

	public static function queueMicrotask(callback: () -> Void): Void {
		init();
		callbacks.push(callback);
		messageChannel.port2.postMessage(js.Lib.undefined);
	}
}
