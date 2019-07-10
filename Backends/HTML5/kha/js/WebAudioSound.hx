package kha.js;

import haxe.io.Bytes;
import js.Browser;
import js.html.XMLHttpRequest;
import kha.audio2.Audio;

/*
class WebAudioChannel extends kha.SoundChannel {
	private var buffer: Dynamic;
	private var startTime: Float;
	private var offset: Float;
	private var source: Dynamic;

	public function new(buffer: Dynamic) {
		super();
		this.offset = 0;
		this.buffer = buffer;
		this.startTime = Audio._context.currentTime;
		this.source = Audio._context.createBufferSource();
		this.source.buffer = this.buffer;
		this.source.connect(Audio._context.destination);
		this.source.start(0);
	}

	override public function play(): Void {
		if (source != null) return;
		super.play();
		startTime = Audio._context.currentTime - offset;
		source.start(0, offset);
	}

	override public function pause(): Void {
		source.stop();
		offset = Audio._context.currentTime - startTime;
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
		else return Math.ceil((Audio._context.currentTime - startTime) * 1000); //Miliseconds
	}

	override public function getLength(): Int {
		return Math.floor(buffer.duration * 1000); //Miliseconds
	}
}
*/
class WebAudioSound extends kha.Sound {
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
			done(this);
		};
		request.send(null);
	}

	private function superUncompress(done: Void->Void): Void {
		super.uncompress(done);
	}

	override public function uncompress(done: Void->Void): Void {
		Audio._context.decodeAudioData(compressedData.getData(),
		function (buffer) {
			var ch0 = buffer.getChannelData(0);
			var len = ch0.length;
			uncompressedData = new kha.arrays.Float32Array(len * 2);
			length = buffer.duration;
			channels = buffer.numberOfChannels;
			if (buffer.numberOfChannels == 1) {
				var idx = 0;
				var i = 0;
				var lidx = len * 2;
				var uncompressInner = function () {

				};
				uncompressInner = function () {
					var chk_len = idx + 11025;
					var next_chk = chk_len > lidx ? lidx : chk_len;
					while(idx < next_chk) {
						uncompressedData[idx] = ch0[i];
						uncompressedData[idx+1] = ch0[i];
						idx += 2;
						++i;
					}
					if (idx < lidx)
						js.Browser.window.setTimeout(uncompressInner,0);
					else {
						compressedData = null;
					}
				};
				uncompressInner();
				js.Browser.window.setTimeout(done,250);
			}
			else {
				var ch1 = buffer.getChannelData(1);
				var idx = 0;
				var i = 0;
				var lidx = len * 2;
				var uncompressInner = function () {

				};
				uncompressInner = function () {
					var chk_len = idx + 11025;
					var next_chk = chk_len > lidx ? lidx : chk_len;
					while(idx < next_chk) {
						uncompressedData[idx] = ch0[i];
						uncompressedData[idx+1] = ch1[i];
						idx += 2;
						++i;
					}
					if (idx < lidx)
						js.Browser.window.setTimeout(uncompressInner,0);
					else {
						compressedData = null;
					}
				};
				uncompressInner();
				js.Browser.window.setTimeout(done,250);
			}
		},
		function () {
			superUncompress(done);
		});
	}

}
