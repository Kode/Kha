package kha.audio1;

import haxe.ds.Vector;

class SoundChannel {
	public var data: Vector<Float>;
	public var volume: Float;
	private var position: Int;
	
	public function new() {
		volume = 1;
		position = 0;
	}
	
	public function nextSample(): Float {
		var sample = data[position];
		++position;
		return sample;
	}
	
	public function ended(): Bool {
		return position >= data.length;
	}
}
