package kha;

class SoundChannel {
	private var wasStopped: Bool;
	
	public function new() { }
	
	public function play(): Void { wasStopped = false; }
	
	public function pause(): Void { }

	public function stop(): Void { wasStopped = true; }

	public function getLength(): Int { return 0; } // Miliseconds
	
	public function getCurrentPos(): Int { return 0; } // Miliseconds
	
	public function getVolume(): Float { return 0; } // [0, 1]

	public function setVolume(volume: Float): Void { } // [0, 1]
	
	public function setPan(pan: Float): Void { } // [-1, 1]
	
	public function getPan(): Float { return 0; } // [-1, 1]
	
	public function isFinished(): Bool {
		return getCurrentPos() >= getLength() || wasStopped;
	}
}
