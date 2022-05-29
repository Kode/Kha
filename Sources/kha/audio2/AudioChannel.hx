package kha.audio2;

import kha.arrays.Float32Array;

@:headerCode("#include <kinc/threads/atomic.h>")
@:headerClassCode("volatile float kinc_volume; volatile int kinc_position; volatile int kinc_paused; volatile int kinc_stopped; volatile int kinc_looping;")
class AudioChannel implements kha.audio1.AudioChannel {
	public var data: Float32Array = null;

#if cpp
	var myVolume(get, set): Float;

	inline function get_myVolume(): Float {
		return untyped __cpp__("kinc_volume");
	}

	inline function set_myVolume(value: Float): Float {
		untyped __cpp__("KINC_ATOMIC_EXCHANGE_FLOAT(&kinc_volume, (float){0})", value);
		return value;
	}

	var myPosition(get, set): Int;

	inline function get_myPosition(): Int {
		return untyped __cpp__("kinc_position");
	}

	inline function set_myPosition(value: Int): Int {
		untyped __cpp__("KINC_ATOMIC_EXCHANGE_32(&kinc_position, {0})", value);
		return value;
	}

	var paused(get, set): Bool;

	inline function get_paused(): Bool {
		return untyped __cpp__("kinc_paused != 0");
	}

	inline function set_paused(value: Bool): Bool {
		untyped __cpp__("KINC_ATOMIC_EXCHANGE_32(&kinc_paused, {0} ? 1 : 0)", value);
		return value;
	}

	var stopped(get, set): Bool;

	inline function get_stopped(): Bool {
		return untyped __cpp__("kinc_stopped != 0");
	}

	inline function set_stopped(value: Bool): Bool {
		untyped __cpp__("KINC_ATOMIC_EXCHANGE_32(&kinc_stopped, {0} ? 1 : 0)", value);
		return value;
	}

	var looping(get, set): Bool;

	inline function get_looping(): Bool {
		return untyped __cpp__("kinc_looping != 0");
	}

	inline function set_looping(value: Bool): Bool {
		untyped __cpp__("KINC_ATOMIC_EXCHANGE_32(&kinc_looping, {0} ? 1 : 0)", value);
		return value;
	}
#else
	var myVolume: Float;
	var myPosition: Int;
	var paused: Bool;
	var stopped: Bool;
	var looping: Bool;
#end

	public function new(looping: Bool) {
		this.looping = looping;
		stopped = false;
		paused = false;
		myPosition = 0;
		myVolume = 1;
	}

	public function nextSamples(requestedSamples: Float32Array, requestedLength: Int, sampleRate: Int): Void {
		if (paused || stopped) {
			for (i in 0...requestedLength) {
				requestedSamples[i] = 0;
			}
			return;
		}

		var requestedSamplesIndex = 0;
		while (requestedSamplesIndex < requestedLength) {
			for (i in 0...min(data.length - myPosition, requestedLength - requestedSamplesIndex)) {
				requestedSamples[requestedSamplesIndex++] = data[myPosition++];
			}

			if (myPosition >= data.length) {
				myPosition = 0;
				if (!looping) {
					stopped = true;
					break;
				}
			}
		}

		while (requestedSamplesIndex < requestedLength) {
			requestedSamples[requestedSamplesIndex++] = 0;
		}
	}

	public function play(): Void {
		paused = false;
		stopped = false;
		kha.audio1.Audio._playAgain(this);
	}

	public function pause(): Void {
		paused = true;
	}

	public function stop(): Void {
		myPosition = 0;
		stopped = true;
	}

	public var length(get, null): Float; // Seconds

	function get_length(): Float {
		return data.length / kha.audio2.Audio.samplesPerSecond / 2; // 44.1 khz in stereo
	}

	public var position(get, set): Float; // Seconds

	function get_position(): Float {
		return myPosition / kha.audio2.Audio.samplesPerSecond / 2;
	}

	function set_position(value: Float): Float {
		myPosition = Math.round(value * kha.audio2.Audio.samplesPerSecond * 2);
		myPosition = max(min(myPosition, data.length), 0);
		return value;
	}

	public var volume(get, set): Float;

	function get_volume(): Float {
		return myVolume;
	}

	function set_volume(value: Float): Float {
		return myVolume = value;
	}

	public var finished(get, null): Bool;

	function get_finished(): Bool {
		return stopped;
	}

	static inline function max(a: Int, b: Int) {
		return a > b ? a : b;
	}

	static inline function min(a: Int, b: Int) {
		return a < b ? a : b;
	}
}
