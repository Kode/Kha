package com.ktxsoftware.kje.backend.js;

import js.Lib;

class Sound implements com.ktxsoftware.kje.Sound {
	var element : Dynamic;
	
	public function new(filename : String) {
		element = Lib.document.createElement("audio");
		element.src = filename + ".mp3";
		//if (element.canPlayType("audio/mp4") == MediaElement.CANNOT_PLAY) element.setSrc(filename + ".ogg");
		//else element.setSrc(filename + ".mp4");
		element.preload = "auto";
	}
	
	public function play() : Void {
		//try {
		//	element.setCurrentTime(0);
		//}
		//catch (Exception ex) { }
		//element.pause();
		//element.currentTime = 0.0;
		try {
			element.currentTime = 0.0;
		}
		catch (e : Dynamic) {
			
		}
		element.play();
	}
	
	public function stop() : Void {
		element.pause();
	}
}