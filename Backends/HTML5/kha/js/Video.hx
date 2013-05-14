package kha.js;

import js.Browser;
import js.html.Event;
import js.html.MediaError;
import js.html.VideoElement;

using StringTools;

class Video extends kha.Video {
	static var extensions = [".webm", ".mp4"];
	public var element : VideoElement;
	
	public function new(filename : String) {
		super();
		
		element = cast(Browser.document.createElement("video"), VideoElement);
		element.preload = "auto";
		
		element.addEventListener("error", errorListener, false);
		element.addEventListener("canplaythrough", canPlayThroughListener, false);
		
		element.src = filename + extensions[0];
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
	
	function errorListener(eventInfo : Event) : Void {
		if (element.error.code == MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED) {
			for ( i in 0 ... extensions.length - 1 ) {
				var ext = extensions[i];
				if ( element.src.endsWith(extensions[i]) ) {
					// try loading with next extension:
					element.src = element.src.substr(0, element.src.length - extensions[i].length) + extensions[i + 1];
					return;
				}
			}
		}
		
		{
			var str = "";
			for ( i in extensions.length - 2 ... 1 ) {
				str = "/" + extensions[i];
			}
			
			trace("Error loading " + element.src + str);
		}
		
		finishAsset();
	}
	
	function canPlayThroughListener(eventInfo : Dynamic) : Void {
		finishAsset();
	}
	
	function finishAsset() {
		element.removeEventListener("error", errorListener, false);
		element.removeEventListener("canplaythrough", canPlayThroughListener,false);
		var l : Loader = cast kha.Loader.the;
		l.finishAsset();
	}
}