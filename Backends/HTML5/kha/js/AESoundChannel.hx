package kha.js;

import js.html.AudioElement;
import kha.audio1.SoundChannel;

class AESoundChannel {
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

	public var length(get, null): Int; // Miliseconds
	
	private function get_length(): Int {
		if (Math.isFinite(element.duration)) {
			return Math.floor(element.duration * 1000);
		}
		else {
			return -1;
		}
	}

	public var position(get, null): Int; // Miliseconds
	
	private function get_position(): Int {
		return Math.ceil(element.currentTime * 1000);
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
