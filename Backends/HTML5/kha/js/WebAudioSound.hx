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
	private var done: kha.Sound -> Void;
	private var buffer: AudioBuffer;
	
	public function new(filename: String, done: kha.Sound -> Void) {
		super();
		this.done = done;
		
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename, true);
		request.responseType = "arraybuffer";
		
		request.onerror = function() {
			trace("Error loading " + filename);
			Browser.console.log("loadSound failed");
		};
		request.onload = function() {
			var arrayBuffer: ArrayBuffer = request.response;
			
			var output = new BytesOutput();
			var header = Reader.readAll(Bytes.ofData(arrayBuffer), output, true);
			var soundBytes = output.getBytes();
			var count = Std.int(soundBytes.length / 4);
			if (header.channel == 1) {
				data = new Vector<Float>(count * 2);
				for (i in 0...count) {
					data[i * 2 + 0] = soundBytes.getFloat(i * 4);
					data[i * 2 + 1] = soundBytes.getFloat(i * 4);
				}
			}
			else {
				data = new Vector<Float>(count);
				for (i in 0...count) {
					data[i] = soundBytes.getFloat(i * 4);
				}
			}
			
			done(this);
		};
		request.send(null);
	}
	
	//override public function play(): kha.SoundChannel {
	//	return new WebAudioChannel(buffer);
	//}
}
