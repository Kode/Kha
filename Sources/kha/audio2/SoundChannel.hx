package kha.audio2;

import haxe.ds.Vector;

class SoundChannel {
	public var data: Vector<Float>;
	public var volume: Float;
	private var position: Int;
	
	public function new() {
		volume = 1;
		position = 0;
	}
	
	public function nextSamples(samples: Vector<Float>): Void {
		for (i in 0...samples.length) {
			samples[i] = position < data.length ? data[position] : 0;
			++position;
		}
	}
	
	public function ended(): Bool {
		return position >= data.length;
	}
}
