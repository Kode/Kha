package kha.cpp;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Sound/Music.h>
')

@:headerClassCode("Kt::Text music;")
class Music implements kha.Music {
	public function new(filename : String) {
		loadMusic(filename);
	}
	
	@:functionCode("music = Kt::Text(filename.c_str());")
	function loadMusic(filename : String) {
		
	}
	
	@:functionCode("Kt::Music::play(music);")
	public function start() : Void {
		
	}
	
	@:functionCode("Kt::Music::stop();")
	public function stop() : Void {
		
	}
	
	public function update() : Void {
		
	}
}