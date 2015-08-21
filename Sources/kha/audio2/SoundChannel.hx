package kha.audio2;

import haxe.ds.Vector;

class SoundChannel implements kha.audio1.SoundChannel {
	public var data: Vector<Float>;
	private var myVolume: Float;
	private var myPosition: Int;
	private var paused: Bool = false;
	
	public function new() {
		myVolume = 1;
		myPosition = 0;
	}
	
	public function nextSamples(samples: Vector<FastFloat>, length: Int, sampleRate: Int): Void {
		if (paused) {
			for (i in 0...length) {
				samples[i] = 0;
			}
			return;
		}
		
		for (i in 0...length) {
			samples[i] = myPosition < data.length ? data[myPosition] : 0;
			++myPosition;
		}
	}
	
	public function play(): Void {
		paused = false;
	}

	public function pause(): Void {
		paused = true;
	}

	public function stop(): Void {
		myPosition = data.length;
	}

	public var length(get, null): Int; // Miliseconds
	
	private function get_length(): Int {
		return Std.int(data.length / 44.1 / 2); // 44.1 khz in stereo
	}

	public var position(get, null): Int; // Miliseconds
	
	private function get_position(): Int {
		return Std.int(myPosition / 44.1 / 2);
	}
	
	public var volume(get, set): Float;
	
	private function get_volume(): Float {
		return myVolume;
	}

	private function set_volume(value: Float): Float {
		return myVolume = value;
	}

	public var finished(get, null): Bool;

	private function get_finished(): Bool {
		return myPosition >= data.length;
	}
}
