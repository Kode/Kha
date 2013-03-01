package kha.cpp;

class SoundChannel extends kha.SoundChannel {
	public function new() {
		super();
	}
	
	override public function play(): Void {
		
	}
	
	override public function stop(): Void {
		
	}
	
	//@:functionCode("return sound->length();")
	override public function getLength(): Int { return 0; } // Miliseconds
	
	//@:functionCode("return sound->position();")
	override public function getCurrentPos(): Int { return 0; } // Miliseconds
}
