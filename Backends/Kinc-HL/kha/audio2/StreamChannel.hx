package kha.audio2;

import haxe.ds.Vector;
import haxe.io.Bytes;

class StreamChannel implements kha.audio1.AudioChannel {
	var _vorbis: Pointer;
	var atend: Bool = false;
	@:keep var loop: Bool;
	var myVolume: Float;
	var paused: Bool = false;

	public function new(data: Bytes, loop: Bool) {
		myVolume = 1;
		this.loop = loop;
		_vorbis = kinc_sound_init_vorbis(data.getData().bytes, data.length);
	}

	public function nextSamples(samples: kha.arrays.Float32Array, length: Int, sampleRate: Int): Void {
		if (paused) {
			for (i in 0...length) {
				samples[i] = 0;
			}
			return;
		}

		atend = kinc_sound_next_vorbis_samples(_vorbis, samples.getData(), length, loop, atend);
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

	public var length(get, never): Float; // Seconds

	function get_length(): Float {
		return kinc_sound_vorbis_get_length(_vorbis);
	}

	public var position(get, set): Float; // Seconds

	function get_position(): Float {
		return kinc_sound_vorbis_get_position(_vorbis);
	}

	function set_position(value: Float): Float {
		return value;
	}

	public var volume(get, set): Float;

	function get_volume(): Float {
		return myVolume;
	}

	function set_volume(value: Float): Float {
		return myVolume = value;
	}

	public var finished(get, never): Bool;

	function get_finished(): Bool {
		return atend;
	}

	@:hlNative("std", "kinc_sound_init_vorbis") static function kinc_sound_init_vorbis(data: Pointer, length: Int): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_sound_next_vorbis_samples") static function kinc_sound_next_vorbis_samples(vorbis: Pointer, samples: Pointer, length: Int,
			loop: Bool, atend: Bool): Bool {
		return false;
	}

	@:hlNative("std", "kinc_sound_vorbis_get_length") static function kinc_sound_vorbis_get_length(vorbis: Pointer): Int {
		return 0;
	}

	@:hlNative("std", "kinc_sound_vorbis_get_position") static function kinc_sound_vorbis_get_position(vorbis: Pointer): Int {
		return 0;
	}
}
