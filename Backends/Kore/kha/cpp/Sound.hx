package kha.cpp;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio/Sound.h>
#include <Kore/Audio/Mixer.h>
')

@:headerClassCode("Kore::Sound* sound;")
class Sound extends kha.Sound {
	public function new(filename: String) {
		super();
		loadSound(filename + ".wav");
	}
	
	@:functionCode("sound = new Kore::Sound(filename.c_str());")
	function loadSound(filename: String) {
		
	}
	
	@:functionCode("Kore::Mixer::play(sound); return null();")
	override public function play(): kha.SoundChannel {
		return null;
	}
	
	@:functionCode("delete sound;")
	override public function unload(): Void {

	}
}