package kha.cpp;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Sound/Sound.h>
')

@:headerClassCode("Kt::Sound::SoundHandle* sound;")
class Sound implements kha.Sound {
	public function new(filename : String) {
		loadSound(filename);
	}
	
	@:functionCode("sound = new Kt::Sound::SoundHandle(Kt::Text(filename.c_str()) + \".wav\", false);")
	function loadSound(filename : String) {
		
	}
	
	@:functionCode("sound->play();")
	public function play() : Void {
		
	}
	
	public function stop() : Void {
		
	}
}