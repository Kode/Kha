package kha.js;

import js.Browser;
import js.html.AudioElement;
import js.html.ErrorEvent;
import js.html.Event;
import js.html.MediaError;

using StringTools;

class SoundChannel extends kha.SoundChannel {
	private var element: Dynamic;
	
	public function new(element: Dynamic) {
		super();
		this.element = element;
	}
	
	override public function play(): Void {
		super.play();
		element.play();
	}
	
	override public function pause() : Void {
		try {
			element.pause();
		} catch ( e : Dynamic ) {
			trace ( e );
		}
	}
	
	override public function stop() : Void {
		try {
			element.pause();
			element.currentTime = 0;
      super.stop();
		} catch (e : Dynamic) {
			trace ( e );
		}
	}
	
	override public function getCurrentPos() : Int {
		return Math.ceil(element.currentTime * 1000);  // Miliseconds
	}
	
	override public function getLength() : Int {
		if ( Math.isFinite(element.duration) ) {
			return Math.floor(element.duration * 1000); // Miliseconds
		} else {
			return -1;
		}
	}
}

class Sound extends kha.Sound {
	static var extensions : Array<String> = null;
	public var element : AudioElement;
	private var done: kha.Sound -> Void;
	
	public function new(filename : String, done: kha.Sound -> Void) {
		super();
		
		this.done = done;
		
		element = cast Browser.document.createElement("audio");
		
		if (extensions == null) {
			extensions = new Array();
			if ( element.canPlayType("audio/ogg") != "" ) {
				extensions.push(".ogg");
			}
			if ( element.canPlayType("audio/mp4") != "" ) {
				extensions.push(".mp4");
			}
		}
		
		element.preload = "auto";
		
		element.addEventListener("error", errorListener, false);
		element.addEventListener("canplaythrough", canPlayThroughListener, false);
		
		element.src = filename + extensions[0];
	}
	
	override public function play(): kha.SoundChannel {
		try {
			element.play();
		} catch ( e : Dynamic ) {
			trace ( e );
		}
		return new SoundChannel(element);
	}
	
	function errorListener(eventInfo: ErrorEvent): Void {
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
			var i = extensions.length - 2;
			while ( i >= 0 ) {
				str = "|" + extensions[i];
			}
			
			trace("Error loading " + element.src + str);
		}
		
		finishAsset();
	}
	
	function canPlayThroughListener(eventInfo : Event) : Void {
		finishAsset();
	}
	
	function finishAsset() {
		element.removeEventListener("error", errorListener, false);
		element.removeEventListener("canplaythrough", canPlayThroughListener,false);
		done(this);
	}
}
