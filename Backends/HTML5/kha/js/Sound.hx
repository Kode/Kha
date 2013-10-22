package kha.js;

import js.Browser;
import js.html.AudioElement;
import js.html.ErrorEvent;
import js.html.Event;
import js.html.MediaError;
import js.Lib;

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
}

class Sound extends kha.Sound {
	private static var extensions: Array<String> = null;
	static var loading : List<Sound> = new List();
	private var done: kha.Sound -> Void;
	public var element: AudioElement;
	
	public function new(filename: String, done: kha.Sound -> Void) {
		super();
		
		this.done = done;
		loading.add(this); // prevent gc from removing this
		
		element = cast Browser.document.createElement("audio");
		
		if (extensions == null) {
			extensions = new Array<String>();
			if (element.canPlayType("audio/ogg") != "") extensions.push(".ogg");
			if (element.canPlayType("audio/mp4") != "") extensions.push(".mp4");
		}
		
		element.addEventListener("error", errorListener, false);
		element.addEventListener("canplay", canPlayThroughListener, false);
		
		element.src = filename + extensions[0];
		element.load();
		if (untyped __js__("!('mozChannels' in this.element)")) {
			element.muted = true;
			element.play(); //force preload
		}
	}
	
	override public function play(): kha.SoundChannel {
		try {
			element.play();
		}
		catch (e: Dynamic) {
			trace(e);
		}
		return new SoundChannel(element);
	}
	
	private function errorListener(eventInfo: ErrorEvent): Void {
		if (element.error.code == MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED) {
			for (i in 0...extensions.length - 1) {
				if (element.src.endsWith(extensions[i])) {
					// try loading with next extension:
					element.src = extractName(element.src) + extensions[i + 1];
					return;
				}
			}
		}
		
		trace("Error loading " + extractName(element.src) + concatExtensions());
		Lib.alert("loadSound failed");
	
		finishAsset();
	}
	
	private static function extractName(filename: String): String {
		return filename.substr(0, filename.lastIndexOf("."));
	}
	
	private static function concatExtensions(): String {
		var value = extensions[0];
		for (i in 1...extensions.length) value += "|" + extensions[i];
		return value;
	}
	
	private function canPlayThroughListener(eventInfo: Event): Void {
		finishAsset();
	}
	
	private function finishAsset() {
		element.removeEventListener("error", errorListener, false);
		element.removeEventListener("canplaythrough", canPlayThroughListener, false);
		if (untyped __js__("!('mozChannels' in this.element)")) {
			element.pause();
			element.currentTime = 0;
			element.muted = false;
		}
		done(this);
		loading.remove(this);
	}
}
