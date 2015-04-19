package kha.js;

import js.Browser;
import js.html.AudioElement;
import js.html.XMLHttpRequest;
import js.Lib;

class WebAudioChannel extends kha.SoundChannel {
	private var buffer: Dynamic;
	private var startTime: Float;
	private var offset: Float;
	private var source: Dynamic;
	
	public function new(buffer: Dynamic) {
		super();
		this.offset = 0;
		this.buffer = buffer;
		this.startTime = Sys.audio.currentTime;
		this.source = Sys.audio.createBufferSource();
		this.source.buffer = this.buffer;
		this.source.connect(Sys.audio.destination);
		this.source.start(0);
	}
	
	override public function play(): Void {
		if (source != null) return;
		super.play();
		startTime = Sys.audio.currentTime - offset;
		source.start(0, offset);
	}
	
	override public function pause(): Void {
		source.stop();
		offset = Sys.audio.currentTime - startTime;
		startTime = -1;
		source = null;
	}
	
	override public function stop(): Void {
		source.stop();
		source = null;
		offset = 0;
		startTime = -1;
		super.stop();
	}
	
	override public function getCurrentPos(): Int {
		if (startTime < 0) return Math.ceil(offset * 1000);
		else return Math.ceil((Sys.audio.currentTime - startTime) * 1000); //Miliseconds
	}
	
	override public function getLength(): Int {
		return Math.floor(buffer.duration * 1000); //Miliseconds
	}
}

class WebAudioSound extends kha.Sound {
	private var done: kha.Sound -> Void;
	private var buffer: Dynamic;
	private static var initialized: Bool = false;
	private static var playsOgg: Bool = false;
	
	private static function init(): Void {
		if (initialized) return;
		var element: AudioElement = cast Browser.document.createElement("audio");
		playsOgg = element.canPlayType("audio/ogg") != "";
		initialized = true;
	}
	
	public function new(filename: String, done: kha.Sound -> Void) {
		super();
		this.done = done;
		
		init();
		
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename + (playsOgg ? ".ogg" : ".mp4"), true);
		request.responseType = "arraybuffer";
		
		request.onerror = function() {
			Browser.alert("loadSound failed");
		};
		request.onload = function() {
			var arrayBuffer = request.response;
			Sys.audio.decodeAudioData(request.response,
			function(buf) {
				buffer = buf;
				done(this);
			},
			function() {
				Browser.alert("loadSound failed");
			}
			);
		};
		request.send(null);
	}
	
	override public function play(): kha.SoundChannel {
		return new WebAudioChannel(buffer);
	}
}
