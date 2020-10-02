package kha.audio2;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

#if (!cpp && !hl)
class StreamChannel implements kha.audio1.AudioChannel {
	#if (!kha_no_ogg)
	private var reader: Reader;
	#end
	private var atend: Bool = false;
	private var loop: Bool;
	private var myVolume: Float;
	private var paused: Bool = false;
	
	public function new(data: Bytes, loop: Bool) {
		myVolume = 1;
		this.loop = loop;
		#if (!kha_no_ogg)
		reader = Reader.openFromBytes(data);
		#end
	}

	public function nextSamples(samples: kha.arrays.Float32Array, length: Int, sampleRate: Int): Void {
		if (paused) {
			for (i in 0...length) {
				samples[i] = 0;
			}
			return;
		}
		
		#if (!kha_no_ogg)
		var count = reader.read(samples, Std.int(length / 2), 2, sampleRate, true) * 2;
		if (count < length) {
			if (loop) {
				reader.currentMillisecond = 0;
			}
			else {
				atend = true;
				onFinishedCallback();
			}
			for (i in count...length) {
				samples[i] = 0;
			}
		}
		#end
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
		#if (kha_no_ogg) return 0.0; #else return reader.totalMillisecond / 1000.0; #end
	}

	public var position(get, set): Float; // Seconds
	
	private function get_position(): Float {
		#if (kha_no_ogg) return 0.0; #else return reader.currentMillisecond / 1000.0; #end
	}

	function set_position(value: Float): Float {
		return value;
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

	public var onFinishedCallback:Void->Void = function(){};
}
#end
