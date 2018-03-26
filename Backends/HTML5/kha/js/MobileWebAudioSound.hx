package kha.js;

import haxe.io.Bytes;
import js.html.XMLHttpRequest;

class MobileWebAudioSound extends kha.Sound {
	public var _buffer: Dynamic;

	public function new(filename: String, done: kha.Sound -> Void, failed: Dynamic -> Void) {
		super();
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename, true);
		request.responseType = "arraybuffer";

		request.onerror = function() {
			failed(filename);
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
					throw "Audio format not supported"; // TODO (DK) use 'failed' callback as well?
				}
			);
		};
		request.send(null);
	}

	override public function uncompress(done: Void->Void): Void {
		done();
	}
}
