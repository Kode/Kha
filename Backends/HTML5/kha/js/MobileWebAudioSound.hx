package kha.js;

import haxe.io.Bytes;
import js.html.XMLHttpRequest;

class MobileWebAudioSound extends kha.Sound {
	public var _buffer: Dynamic;

	public function new(filename: String, done: kha.Sound -> Void, failed: AssetError -> Void) {
		super();
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename, true);
		request.responseType = "arraybuffer";

		request.onerror = function() {
			failed({ url: filename });
		};

		request.onload = function() {
			compressedData = Bytes.ofData(request.response);
			uncompressedData = null;
			MobileWebAudio._context.decodeAudioData(compressedData.getData(),
				function (buffer) {
					length = buffer.duration;
					channels = buffer.numberOfChannels;
					_buffer = buffer;
					done(this);
				},
				function () {
					failed({ url: filename, error: 'Audio format not supported' });
				}
			);
		};
		request.send(null);
	}

	override public function uncompress(done: Void->Void): Void {
		done();
	}
}
