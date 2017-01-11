package kha.js;

import js.html.audio.AudioBufferSourceNode;

class MobileWebAudioChannel implements kha.audio1.AudioChannel {
	private var source: AudioBufferSourceNode;
	
	public function new(source: AudioBufferSourceNode) {
		this.source = source;
	}
	
	public function play(): Void {
		source.start(0);
	}

	public function pause(): Void {
		source.stop();
	}

	public function stop(): Void {
		source.stop();
	}

	public var length(get, null): Float; // Seconds
	
	private function get_length(): Float {
		return Math.POSITIVE_INFINITY;
	}

	public var position(get, null): Float; // Seconds
	
	private function get_position(): Float {
		return 0;
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
		return false;
	}
}
