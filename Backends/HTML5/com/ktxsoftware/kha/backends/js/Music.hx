package com.ktxsoftware.kha.backends.js;

import js.Lib;

class Music implements com.ktxsoftware.kha.Music {
	var element : Dynamic;
	
	public function new(filename : String) {
		element = Lib.document.createElement("audio");
		element.loop = "true"; //not working in Firefox until version 11
		if (!element.canPlayType("audio/mp4")) element.src = filename + ".ogg";
		else element.src = filename + ".mp4";
		element.load();
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