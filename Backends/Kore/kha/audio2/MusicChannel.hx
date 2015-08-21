package kha.audio2;

import haxe.ds.Vector;
import haxe.io.Bytes;

@:headerCode('#include <Kore/Audio/stb_vorbis.h>')

@:headerClassCode('stb_vorbis* vorbis;')
class MusicChannel implements kha.audio1.MusicChannel {
	private var atend: Bool = false;
	private var loop: Bool;
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
		int read = stb_vorbis_get_samples_float_interleaved(vorbis, 2, samples->Pointer(), length);
		if (read < length / 2) {
			if (loop) {
				stb_vorbis_seek_start(vorbis);
			}
			else {
				atend = true;
			}
			for (int i = read; i < length; ++i) {
				samples->Pointer()[i] = 0;
			}
		}
	')
	private function nextVorbisSamples(samples: Vector<FastFloat>, length: Int): Void {
		
	}

	public function nextSamples(samples: Vector<FastFloat>, length: Int, sampleRate: Int): Void {
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

	public var length(get, null): Int; // Miliseconds
	
	@:functionCode('
		if (vorbis == NULL) return 0;
		return stb_vorbis_stream_length_in_seconds(vorbis) * 1000;
	')
	private function get_length(): Int {
		return 0;
	}

	public var position(get, null): Int; // Miliseconds
	
	@:functionCode('
		 if (vorbis == NULL) return 0;
		return stb_vorbis_get_sample_offset(vorbis) / stb_vorbis_stream_length_in_samples(vorbis) * 1000;
	')
	private function get_position(): Int {
		return 0;
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
