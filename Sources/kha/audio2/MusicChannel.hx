package kha.audio2;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

class MusicChannel {
	public var volume: Float;
	private static inline var bufferSize = 256;
	private var buffer: Vector<Float>;
	private var reader: Reader;
	private var position: Int;
	private var count: Int;
	private var atend: Bool = false;
	private var loop: Bool;
	
	public function new(data: Bytes, loop: Bool) {
		volume = 1;
		this.loop = loop;
		buffer = new Vector<Float>(bufferSize);
		reader = Reader.openFromBytes(data);
		updateBuffer();
	}
	
	private function updateBuffer(): Void {
		var output = new BytesOutput();
		count = reader.read(output, Std.int(buffer.length / 2), 2, 44100, true) * 2;
		if (count == 0) {
			if (loop) {
				reader.currentMillisecond = 0;
				updateBuffer();
			}
			else {
				atend = true;
				for (i in 0...16) buffer[i] = 0;
				position = 0;
			}
		}
		else {
			position = 0;
			var bytes = output.getBytes();
			for (i in 0...count) {
				buffer[i] = bytes.getFloat(i * 4);
			}
		}
	}
	
	public function nextSample(): Float {
		if (position >= count) {
			updateBuffer();
		}
		var sample = buffer[position];
		++position;
		return sample;
	}
	
	public function ended(): Bool {
		return atend;
	}
}
