package kha.cpp;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Sound/Sound.h>
')

@:headerClassCode("Kt::Sound::SoundHandle* sound;")
class Sound extends kha.Sound {
	public function new(filename : String) {
		super();
		loadSound(filename);
	}
	
	@:functionCode("sound = new Kt::Sound::SoundHandle(Kt::Text(filename.c_str()) + \".wav\", false);")
	function loadSound(filename : String) {
		
	}
	
	@:functionCode("sound->play();")
	override public function play() : Void {
		
	}
	
	override public function stop() : Void {
		
	}
	
	@:functionCode("delete sound;")
	override public function unload():Void {

	}
}