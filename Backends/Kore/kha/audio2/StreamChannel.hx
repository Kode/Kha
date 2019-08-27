package kha.audio2;

import haxe.io.Bytes;

@:headerCode('#define STB_VORBIS_HEADER_ONLY\n#include <kinc/audio1/stb_vorbis.c>')

@:headerClassCode('stb_vorbis* vorbis;')
class StreamChannel implements kha.audio1.AudioChannel {
	private var atend: Bool = false;
	@:keep private var loop: Bool;
	private var myVolume: Float;
	private var paused: Bool = false;
	
	public function new(data: Bytes, loop: Bool) {
		myVolume = 1;
		this.loop = loop;
		initVorbis(data);
	}
	
	@:functionCode('vorbis = stb_vorbis_open_memory(data->b->Pointer(), data->length, NULL, NULL);')
	private function initVorbis(data: Bytes): Void {
		
	}
	
	@:functionCode('
		int read = stb_vorbis_get_samples_float_interleaved(vorbis, 2, samples->self.data, length);
		if (read < length / 2) {
			if (loop) {
				stb_vorbis_seek_start(vorbis);
			}
			else {
				atend = true;
			}
			for (int i = read; i < length; ++i) {
				samples->self.data[i] = 0;
			}
		}
	')
	private function nextVorbisSamples(samples: kha.arrays.Float32Array, length: Int): Void {
		
	}

	public function nextSamples(samples: kha.arrays.Float32Array, length: Int, sampleRate: Int): Void {
		if (paused) {
			for (i in 0...length) {
				samples[i] = 0;
			}
			return;
		}
		
		nextVorbisSamples(samples, length);
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
	
	@:functionCode('
		if (vorbis == NULL) return 0;
		return stb_vorbis_stream_length_in_seconds(vorbis);
	')
	private function get_length(): Int {
		return 0;
	}

	public var position(get, set): Float; // Seconds
	
	@:functionCode('
		 if (vorbis == NULL) return 0;
		return stb_vorbis_get_sample_offset(vorbis) / stb_vorbis_stream_length_in_samples(vorbis);
	')
	private function get_position(): Float {
		return 0;
	}

	private function set_position(value: Float): Float {
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
}
