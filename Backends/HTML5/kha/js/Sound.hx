package kha.js;

import js.Lib;

class Sound extends kha.Sound {
	public var element : Dynamic;
	
	public function new(filename : String) {
		super();
		
		element = Lib.document.createElement("audio");
		element.preload = "auto";
		
		if (!element.canPlayType("audio/mp4")) element.src = filename + ".ogg";
		else element.src = filename + ".mp4";
	}
	
	override public function play() : Void {
		element.play();
	}
	
	override public function pause() : Void {
		element.pause();
	}
	
	override public function stop() : Void {
		element.pause();
		element.currentTime = 0.0;
	}
	
	override public function getCurrentPos() : Int {
		return Math.ceil(element.currentTime * 1000);  // Miliseconds
	}
	
	override public function getLength() : Int {
		return Math.floor(element.duration * 1000); // Miliseconds
	}
}