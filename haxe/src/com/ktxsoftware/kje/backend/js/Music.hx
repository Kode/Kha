package com.ktxsoftware.kje.backend.js;

import js.Lib;

class Music implements com.ktxsoftware.kje.Music {
	var element : Dynamic;
	
	public function new(filename : String) {
		element = Lib.document.createElement("audio");
		element.src = filename + ".mp3";
		element.loop = "true";
		//if (element.canPlayType("audio/mp4") == MediaElement.CANNOT_PLAY) element.setSrc(filename + ".ogg");
		//else element.setSrc(filename + ".mp4");
		element.preload = "auto";
	}
	
	public function start() : Void {
		element.play();
	}
	
	public function stop() : Void {
		element.pause();
	}
	
	public function update() : Void {
		
	}
}