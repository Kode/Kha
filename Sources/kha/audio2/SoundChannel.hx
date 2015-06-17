package kha.audio2;

import haxe.ds.Vector;

class SoundChannel {
	public var data: Vector<Float>;
	private var myVolume: Float;
	private var myPosition: Int;
	
	public function new() {
		myVolume = 1;
		myPosition = 0;
	}
	
	public function nextSamples(samples: Vector<Float>): Void {
		for (i in 0...samples.length) {
			samples[i] = myPosition < data.length ? data[myPosition] : 0;
			++myPosition;
		}
	}
	
	public function play(): Void {
		
	}

	public function pause(): Void {
		
	}

	public function stop(): Void {
		
	}

	public var length(get, null): Int; // Miliseconds
	
	private function get_length(): Int {
		return 0;
	}

	public var position(get, null): Int; // Miliseconds
	
	private function get_position(): Int {
		return 0;
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
