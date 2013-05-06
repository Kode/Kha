package kha.js;

import js.Browser;

class Music extends kha.Music {
	var element : Dynamic;
	
	public function new(filename : String) {
		super();
		element = Browser.document.createElement("audio");
		element.loop = "true"; //not working in Firefox until version 11
		if (!element.canPlayType("audio/mp4")) element.src = filename + ".ogg";
		else element.src = filename + ".mp4";
		element.load();
	}
	
	public function start() : Void {
		element.play();
	}
	
	override public function stop() : Void {
		element.pause();
	}
	
	public function update() : Void {
		
	}
}