package kha.cpp;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio/Sound.h>
')

//@:headerClassCode("Kt::Text music;")
class Music extends kha.Music {
	public function new(filename : String) {
		super();
		loadMusic(filename);
	}
	
	//@:functionCode("music = Kt::Text(filename.c_str());")
	function loadMusic(filename : String) {
		
	}
	
	//@:functionCode("Kt::Music::play(music);")
	override public function play() : Void {
		
	}
	
	//@:functionCode("Kt::Music::stop();")
	override public function stop() : Void {
		
	}
}
