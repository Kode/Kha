package kha.js;

import js.Lib;

class Sound extends kha.Sound {
	var element : Dynamic;
	
	public function new(filename : String) {
		super();
		element = Lib.document.createElement("audio");
		if (!element.canPlayType("audio/mp4")) element.src = filename + ".ogg";
		else element.src = filename + ".mp4";
		element.load();
	}
	
	override public function play() : Void {
		try {
			element.currentTime = 0;
		}
		catch (ex : Dynamic) { }
		element.play();
	}
	
	override public function stop() : Void {
		element.pause();
	}
}