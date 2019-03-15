package kha.audio2;

import haxe.ds.Vector;
import haxe.io.Bytes;

class StreamChannel implements kha.audio1.AudioChannel {
	private var _vorbis:Pointer;
	private var atend: Bool = false;
	@:keep private var loop: Bool;
	private var myVolume: Float;
	private var paused: Bool = false;
	
	public function new(data: Bytes, loop: Bool) {
		myVolume = 1;
		this.loop = loop;
		_vorbis = kore_sound_init_vorbis(data.getData().bytes, data.length);
	}

	public function nextSamples(samples: kha.arrays.Float32Array, length: Int, sampleRate: Int): Void {
		if (paused) {
			for (i in 0...length) {
				samples[i] = 0;
			}
			return;
		}
		
		atend = kore_sound_next_vorbis_samples(_vorbis, samples.getData(), length, loop, atend);
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
		return kore_sound_vorbis_get_length(_vorbis);
	}

	public var position(get, set): Float; // Seconds
	
	private function get_position(): Float {
		return kore_sound_vorbis_get_position(_vorbis);
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

	@:hlNative("std", "kore_sound_init_vorbis") static function kore_sound_init_vorbis(data: Pointer, length: Int): Pointer { return null; }
	@:hlNative("std", "kore_sound_next_vorbis_samples") static function kore_sound_next_vorbis_samples(vorbis: Pointer, samples: Pointer, length: Int, loop: Bool, atend: Bool): Bool { return false; }
	@:hlNative("std", "kore_sound_vorbis_get_length") static function kore_sound_vorbis_get_length(vorbis: Pointer): Int { return 0; }
	@:hlNative("std", "kore_sound_vorbis_get_position") static function kore_sound_vorbis_get_position(vorbis: Pointer): Int { return 0; }
}
