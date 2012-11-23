package kha.js;

import js.Lib;

class Video extends kha.Video {
	public var element : Dynamic;
	
	public function new(filename : String) {
		super();
		
		element = Lib.document.createElement("video");
		element.preload = "auto";
		
		if (!element.canPlayType("video/webm")) element.src = filename + ".mp4";
		else element.src = filename + ".webm";
	}
	
	override public function play() : Void {
		element.play();
	}
	
	override public function pause() : Void {
		element.pause();
	}
	
	override public function stop() : Void {
		element.pause();
		element.currentTime = 0;
	}
	
	override public function getCurrentPos() : Int {
		return Math.ceil(element.currentTime * 1000);  // Miliseconds
	}
	
	override public function getLength() : Int {
		return Math.floor(element.duration * 1000); // Miliseconds
	}
}