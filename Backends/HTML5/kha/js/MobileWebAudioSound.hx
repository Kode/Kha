package kha.js;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import js.Browser;
import js.html.ArrayBuffer;
import js.html.audio.AudioBuffer;
import js.html.AudioElement;
import js.html.XMLHttpRequest;
import js.Lib;

using StringTools;

class MobileWebAudioSound extends kha.Sound {
	public var _buffer: Dynamic;

	public function new(filename: String, done: kha.Sound -> Void) {
		super();
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename, true);
		request.responseType = "arraybuffer";
		
		request.onerror = function() {
			trace("Error loading " + filename);
		};
		
		request.onload = function() {
			compressedData = Bytes.ofData(request.response);
			uncompressedData = null;
			MobileWebAudio._context.decodeAudioData(compressedData.getData(),
				function (buffer) {
					_buffer = buffer;
					done(this);
				},
				function () {
					throw "Audio format not supported";
				}
			);
		};
		request.send(null);
	}
	
	override public function uncompress(done: Void->Void): Void {
		done();
	}
}
