package kha.js;

import js.html.AudioElement;
import kha.audio1.AudioChannel;

class AEAudioChannel implements kha.audio1.AudioChannel {
	var element: AudioElement;
	var stopped = false;
	var looping: Bool;
	
	public function new(element: AudioElement, looping: Bool) {
		this.element = element;
		this.looping = looping;
	}
	
	public function play(): Void {
		stopped = false;
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
			stopped = true;
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
			return Math.POSITIVE_INFINITY;
		}
	}

	public var position(get, set): Float; // Seconds
	
	private function get_position(): Float {
		return element.currentTime;
	}

	function set_position(value: Float): Float {
		return element.currentTime = value;
	}

	public var volume(get, set): Float;

	private function get_volume(): Float {
		return element.volume;
	}

	private function set_volume(value: Float): Float {
		return element.volume = value;
	}

	public var finished(get, null): Bool;

	private function get_finished(): Bool {
		return stopped || (!looping && position >= length);
	}
}
