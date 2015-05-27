package kha.kore;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio/Sound.h>
#include <Kore/Audio/Mixer.h>
')

@:headerClassCode("Kore::Sound* sound;")
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
	
	@:functionCode('return sound->volume();')
	override public function getVolume(): Float { return 1; }

	@:functionCode('sound->setVolume(volume);')
	override public function setVolume(volume: Float): Void { }
}
