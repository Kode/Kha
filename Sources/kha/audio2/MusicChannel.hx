package kha.audio2;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

class MusicChannel {
	public var volume: Float;
	private var reader: Reader;
	private var atend: Bool = false;
	private var loop: Bool;
	
	public function new(data: Bytes, loop: Bool) {
		volume = 1;
		this.loop = loop;
		reader = Reader.openFromBytes(data);
	}

	public function nextSamples(samples: Vector<Float>): Void {
		var count = reader.read(samples, Std.int(samples.length / 2), 2, 44100, true) * 2;
		if (count < samples.length) {
			if (loop) {
				reader.currentMillisecond = 0;
			}
			else {
				atend = true;
			}
			for (i in count...samples.length) {
				samples[i] = 0;
			}
		}
	}
	
	public function ended(): Bool {
		return atend;
	}
}
