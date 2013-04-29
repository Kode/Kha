package kha.js;

import js.Browser;
import js.html.VideoElement;

class Video extends kha.Video {
	public var element: VideoElement;
	
	public function new(filename: String) {
		super();
		
		element = Browser.document.createVideoElement();
		element.preload = "auto";
		
		if (element.canPlayType("video/webm") != "") element.src = filename + ".mp4";
		else element.src = filename + ".webm";
	}
	
	override public function play(): Void {
		element.play();
	}
	
	override public function pause(): Void {
		element.pause();
	}
	
	override public function stop(): Void {
		element.pause();
		element.currentTime = 0;
	}
	
	override public function getCurrentPos(): Int {
		return Math.ceil(element.currentTime * 1000);  // Miliseconds
	}
	
	override public function getLength(): Int {
		return Math.floor(element.duration * 1000); // Miliseconds
	}
}
