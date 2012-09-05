package kha.js;

import js.Lib;

class Video {
	public var element : Dynamic;
	
	public function new(filename : String) {
		element = Lib.document.createElement("video");
		if (!element.canPlayType("video/mp4")) element.src = filename + ".webm";
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