package kha.audio1;

class MusicChannel {
	public var volume: Float;
	
	public function new() {
		volume = 1;
	}
	
	public function nextSample(): Float {
		return 0;
	}
	
	public function ended(): Bool {
		return true;
	}
}
