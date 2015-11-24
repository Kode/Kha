package kha.js;

import js.html.AudioElement;
import kha.audio1.AudioChannel;

class AEAudioChannel implements kha.audio1.AudioChannel {
	private var element: AudioElement;
	
	public function new(sound: Sound) {
		this.element = sound.element;
	}
	
	public function play(): Void {
		element.play();
	}

	public function pause(): Void {
		try {
			element.pause();
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}

	public function stop(): Void {
		try {
			element.pause();
			element.currentTime = 0;
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}

	public var length(get, null): Float; // Seconds
	
	private function get_length(): Float {
		if (Math.isFinite(element.duration)) {
			return element.duration;
		}
		else {
			return -1;
		}
	}

	public var position(get, null): Float; // Seconds
	
	private function get_position(): Float {
		return element.currentTime;
	}

	public var volume(get, set): Float;

	private function get_volume(): Float {
		return 1;
	}

	private function set_volume(value: Float): Float {
		return 1;
	}

	public var finished(get, null): Bool;

	private function get_finished(): Bool {
		return position >= length;
	}
}
