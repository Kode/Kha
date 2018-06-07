package kha.audio2;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

#if (!cpp && !hl)
class StreamChannel implements kha.audio1.AudioChannel {
	private var reader: Reader;
	private var atend: Bool = false;
	private var loop: Bool;
	private var myVolume: Float;
	private var paused: Bool = false;
	
	public function new(data: Bytes, loop: Bool) {
		myVolume = 1;
		this.loop = loop;
		reader = Reader.openFromBytes(data);
	}

	public function nextSamples(samples: kha.arrays.Float32Array, length: Int, sampleRate: Int): Void {
		if (paused) {
			for (i in 0...length) {
				samples[i] = 0;
			}
			return;
		}
		
		var count = reader.read(samples, Std.int(length / 2), 2, sampleRate, true) * 2;
		if (count < length) {
			if (loop) {
				reader.currentMillisecond = 0;
			}
			else {
				atend = true;
			}
			for (i in count...length) {
				samples[i] = 0;
			}
		}
	}
	
	public function play(): Void {
		paused = false;
	}

	public function pause(): Void {
		paused = true;
	}

	public function stop(): Void {
		atend = true;
	}

	public var length(get, null): Float; // Seconds
	
	private function get_length(): Float {
		return reader.totalMillisecond / 1000.0;
	}

	public var position(get, null): Float; // Seconds
	
	private function get_position(): Float {
		return reader.currentMillisecond / 1000.0;
	}
	
	public var volume(get, set): Float;
	
	private function get_volume(): Float {
		return myVolume;
	}

	private function set_volume(value: Float): Float {
		return myVolume = value;
	}

	public var finished(get, null): Bool;

	private function get_finished(): Bool {
		return atend;
	}
}
#end
