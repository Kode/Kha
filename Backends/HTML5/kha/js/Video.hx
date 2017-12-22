package kha.js;

import js.Browser;
import js.html.ErrorEvent;
import js.html.Event;
import js.html.MediaError;
import js.html.VideoElement;

using StringTools;

class Video extends kha.Video {
	private var filenames: Array<String>;
	public var element: VideoElement;
	private var done: kha.Video -> Void;
	public var texture: Image;
	
	private function new() {
		super();
	}

	public static function fromElement(element: js.html.VideoElement): Video {
		var video = new Video();
		video.element = element;
		if (SystemImpl.gl != null) video.texture = Image.fromVideo(video);
		return video;
	}

	public static function fromFile(filenames: Array<String>, done: kha.Video -> Void): Void {
		var video = new Video();

		video.done = done;
		
		video.element = cast Browser.document.createElement("video");
		
		video.filenames = [];
		for (filename in filenames) {
			if (video.element.canPlayType("video/webm") != "" && filename.endsWith(".webm")) video.filenames.push(filename);
#if !kha_debug_html5
			if (video.element.canPlayType("video/mp4") != "" && filename.endsWith(".mp4")) video.filenames.push(filename);
#end
		}
		
		video.element.addEventListener("error", video.errorListener, false);
		video.element.addEventListener("canplaythrough", video.canPlayThroughListener, false);
		
		video.element.preload = "auto";
		video.element.src = video.filenames[0];
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

	override private function get_position(): Int {
		return Math.ceil(element.currentTime * 1000);
	}

	override private function set_position(value: Int): Int {
		element.currentTime = value / 1000;
		return value;
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
	}
}
