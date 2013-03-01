package kha.cpp;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Sound/Sound.h>
')

@:headerClassCode("Kt::Sound::SoundHandle* sound;")
class Sound extends kha.Sound {
	public function new(filename: String) {
		super();
		loadSound(filename);
	}
	
	@:functionCode("sound = new Kt::Sound::SoundHandle(Kt::Text(filename.c_str()) + \".wav\", false);")
	function loadSound(filename: String) {
		
	}
	
	@:functionCode("sound->play(); return null();")
	override public function play(): kha.SoundChannel {
		return null;
	}
	
	@:functionCode("delete sound;")
	override public function unload(): Void {

	}
}