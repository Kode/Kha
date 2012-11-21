package kha.js;

import js.Lib;

class Video extends kha.Video {
	public var element : Dynamic;
	
	public function new(filename : String) {
		super();
		element = Lib.document.createElement("video");
		if (!element.canPlayType("video/webm")) element.src = filename + ".mp4";
		else element.src = filename + ".webm";
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
	
	override public function getCurrentPos() : Int {
		return Std.int(element.currentTime * 1000);  // Miliseconds
	}
	
	override public function getLength() : Int {
		return Std.int(element.duration * 1000); // Miliseconds
	}
}