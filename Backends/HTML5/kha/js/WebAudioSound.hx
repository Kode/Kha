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
import kha.audio2.Audio;
import kha.audio2.ogg.vorbis.Reader;

using StringTools;

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
			uncompressedData = new Vector<Float>(buffer.getChannelData(0).length * 2);
			if (buffer.numberOfChannels == 1) {
				for (i in 0...buffer.getChannelData(0).length) {
					uncompressedData[i * 2 + 0] = buffer.getChannelData(0)[i];
					uncompressedData[i * 2 + 1] = buffer.getChannelData(0)[i];
				}
			}
			else {
				for (i in 0...buffer.getChannelData(0).length) {
					uncompressedData[i * 2 + 0] = buffer.getChannelData(0)[i];
					uncompressedData[i * 2 + 1] = buffer.getChannelData(1)[i];
				}
			}
			compressedData = null;
			done();
		},
		function () {
			superUncompress(done);
		});
	}
}
