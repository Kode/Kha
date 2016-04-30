package kha.js;

import js.Browser;
import js.html.AudioElement;
import js.html.ErrorEvent;
import js.html.Event;
import js.html.MediaError;
import js.Lib;

using StringTools;

/*class SoundChannel extends kha.SoundChannel {
	private var element: Dynamic;
	
	public function new(element: Dynamic) {
		super();
		this.element = element;
	}
	
	override public function play(): Void {
		super.play();
		element.play();
	}
	
	override public function pause(): Void {
		try {
			element.pause();
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}
	
	override public function stop(): Void {
		try {
			element.pause();
			element.currentTime = 0;
			super.stop();
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}
	
	override public function getCurrentPos(): Int {
		return Math.ceil(element.currentTime * 1000);  // Miliseconds
	}
	
	override public function getLength(): Int {
		if (Math.isFinite(element.duration)) {
			return Math.floor(element.duration * 1000); // Miliseconds
		}
		else {
			return -1;
		}
	}
}*/

class Sound extends kha.Sound {
	private var filenames: Array<String>;
	static var loading: Array<Sound> = new Array();
	private var done: kha.Sound -> Void;
	public var element: AudioElement;
	
	public function new(filenames: Array<String>, done: kha.Sound -> Void) {
		super();
		
		this.done = done;
		loading.push(this); // prevent gc from removing this
		
		element = Browser.document.createAudioElement();
		
		this.filenames = [];
		for (filename in filenames) {
			if (element.canPlayType("audio/ogg") != "" && filename.endsWith(".ogg")) this.filenames.push(filename);
			if (element.canPlayType("audio/mp4") != "" && filename.endsWith(".mp4")) this.filenames.push(filename);
		}
		
		element.addEventListener("error", errorListener, false);
		element.addEventListener("canplay", canPlayThroughListener, false);
		
		element.src = this.filenames[0];
		element.preload = "auto";
		element.load();
	}
	
	//override public function play(): kha.SoundChannel {
	//	try {
	//		element.play();
	//	}
	//	catch (e: Dynamic) {
	//		trace(e);
	//	}
	//	return new SoundChannel(element);
	//}
	
	private function errorListener(eventInfo: ErrorEvent): Void {
		if (element.error.code == MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED) {
			for (i in 0...filenames.length - 1) {
				if (element.src == filenames[i]) {
					// try loading with next extension:
					element.src = filenames[i + 1];
					return;
				}
			}
		}
		
		trace("Error loading " + element.src);
		Browser.console.log("loadSound failed");
	
		finishAsset();
	}
	
	private function canPlayThroughListener(eventInfo: Event): Void {
		finishAsset();
	}
	
	private function finishAsset() {
		element.removeEventListener("error", errorListener, false);
		element.removeEventListener("canplaythrough", canPlayThroughListener, false);
		done(this);
		loading.remove(this);
	}
	
	override public function uncompress(done: Void->Void): Void {
		done();
	}
}
