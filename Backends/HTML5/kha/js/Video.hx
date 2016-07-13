package kha.js;

import js.Browser;
import js.html.ErrorEvent;
import js.html.Event;
import js.html.MediaError;
import js.html.VideoElement;

using StringTools;

class Video extends kha.Video {
	private var filenames: Array<String>;
	static var loading : List<Video> = new List(); 
	public var element : VideoElement;
	private var done: kha.Video -> Void;
	public var texture: Image;
	
	public function new(filenames: Array<String>, done: kha.Video -> Void) {
		super();
		
		this.done = done;
		loading.add(this); // prevent gc from removing this
		
		element = cast Browser.document.createElement("video");
		
		this.filenames = [];
		for (filename in filenames) {
			if (element.canPlayType("video/webm") != "" && filename.endsWith(".webm")) this.filenames.push(filename);
#if !sys_debug_html5
			if ( element.canPlayType("video/mp4") != "" && filename.endsWith(".mp4")) this.filenames.push(filename);
#end
		}
		
		element.addEventListener("error", errorListener, false);
		element.addEventListener("canplaythrough", canPlayThroughListener, false);
		
		element.preload = "auto";
		element.src = this.filenames[0];
	}

	override public function width(): Int{
		return element.videoWidth;
	}
	
	override public function height(): Int{
		return element.videoHeight;
	}
	
	override public function play(loop: Bool = false): Void {
		try {
			element.loop = loop;
			element.play();
		}
		catch (e: Dynamic) {
			trace (e);
		}
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
		finishAsset();
	}
	
	function canPlayThroughListener(eventInfo: Event): Void {
		finishAsset();
	}
	
	function finishAsset() {
		element.removeEventListener("error", errorListener, false);
		element.removeEventListener("canplaythrough", canPlayThroughListener, false);
		if (SystemImpl.gl != null) texture = Image.fromVideo(this);
		done(this);
		loading.remove(this);
	}
}
