package kha;

// This class is used for dynamic media like sounds or videos
class Media 
{
	public function new() { }
	
	public function play() { }
	
	public function pause() { }

	public function stop() { }

	public function getLength() : Int { return 0; } // Miliseconds
	
	public function getCurrentPos() : Int { return 0; } // Miliseconds
	
	public function getVolume() : Float { return 0; } // [0, 1]

	public function setVolume() : Float { return 0; } // [0, 1]
	
	public function isFinished() : Bool {
		return getCurrentPos() >= getLength();
	}
	
}