package kha.js;

import js.html.XMLHttpRequest;
import js.Lib;

class WebAudioSound extends kha.Sound {
	private var done: kha.Sound -> Void;
	private var buffer: Dynamic;
	
	public function new(filename : String, done: kha.Sound -> Void) {
		super();
		this.done = done;
		
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename + ".ogg", true);
		request.responseType = "arraybuffer";
		
		request.onerror = function() {
			Lib.alert("loadSound failed");
		};
		request.onload = function() {
			var arrayBuffer = request.response;
			Sys.audio.decodeAudioData(request.response,
			function(buf) {
				buffer = buf;
				done(this);
			},
			function() {
				Lib.alert("loadSound failed");
			}
			);
		};
		request.send(null);
	}
	
	override public function play(): kha.SoundChannel {
		var source: Dynamic = Sys.audio.createBufferSource();
		source.buffer = buffer;
		source.connect(Sys.audio.destination);
		source.start(0);  
		return null;
	}
}
