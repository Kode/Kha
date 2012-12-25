package kha;

// This class is used for dynamic media like sounds or videos
class Media implements Resource {
	public function new() : Void { }
	
	public function play() : Void { }
	
	public function pause() : Void { }

	public function stop() : Void { }

	public function getLength() : Int { return 0; } // Miliseconds
	
	public function getCurrentPos() : Int { return 0; } // Miliseconds
	
	public function getVolume() : Float { return 0; } // [0, 1]

	public function setVolume(volume : Float) : Void { } // [0, 1]
	
	public function isFinished() : Bool {
		return getCurrentPos() >= getLength();
	}
	
	public function unload(): Void {
		
	}
}