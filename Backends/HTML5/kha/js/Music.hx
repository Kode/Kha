package kha.js;

import js.Browser;

class Music extends kha.Music {
	var element : Dynamic;
	
	public function new(filename : String) {
		super();
		element = Browser.document.createElement("audio");
		if (element.canPlayType("audio/ogg")) element.src = filename + ".ogg";
		else element.src = filename + ".mp4";
		element.load();
	}
	
	override public function play(loop: Bool = false) : Void {
		element.loop = (loop ? "true" : "false"); //not working in Firefox until version 11
		element.play();
	}
	
	override public function stop() : Void {
		element.pause();
	}
}