package kha.audio2;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

class MusicChannel {
	public var volume: Float;
	private var buffer: Vector<Float>;
	private var reader: Reader;
	private var position: Int;
	private static inline var bufferSize = 64;
	
	public function new(data: Bytes) {
		volume = 1;
		buffer = new Vector<Float>(bufferSize);
		reader = Reader.openFromBytes(data);
		updateBuffer();
	}
	
	private function updateBuffer(): Void {
		var output = new BytesOutput();
		var count = reader.read(output, buffer.length, 2, 44100, true);
		position = 0;
		var bytes = output.getBytes();
		for (i in 0...count * 2) {
			buffer[i] = bytes.getFloat(i * 4);
		}
	}
	
	public function nextSample(): Float {
		if (position >= buffer.length) {
			updateBuffer();
		}
		var sample = buffer[position];
		++position;
		return sample;
	}
	
	public function ended(): Bool {
		return false;
	}
}
