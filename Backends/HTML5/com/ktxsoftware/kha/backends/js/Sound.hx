package com.ktxsoftware.kha.backends.js;

import js.Dom;
import js.Lib;

class Sound implements com.ktxsoftware.kha.Sound {
	var element : Dynamic;
	
	public function new(filename : String) {
		element = Lib.document.createElement("audio");
		if (!element.canPlayType("audio/mp4")) element.src = filename + ".ogg";
		else element.src = filename + ".mp4";
		element.load();
	}
	
	public function play() : Void {
		try {
			element.currentTime = 0;
		}
		catch (ex : Dynamic) { }
		element.play();
	}
	
	public function stop() : Void {
		element.pause();
	}
}