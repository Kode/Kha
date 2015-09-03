package kha.js;

import haxe.io.Bytes;
import js.Browser;
import js.html.XMLHttpRequest;

class WebAudioMusic extends kha.Music {
	public var aemusic: kha.js.Music;
	
	public function new(aemusic: kha.js.Music, filename: String, done: kha.Music -> Void) {
		super();
		
		this.aemusic = aemusic;
		
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename, true);
		request.responseType = "arraybuffer";
		
		request.onerror = function() {
			trace("Error loading " + filename);
			Browser.console.log("loadMusic failed");
		};
		request.onload = function() {
			var arrayBuffer = request.response;
			data = Bytes.ofData(arrayBuffer);
			done(this);
		};
		request.send(null);
	}
}
