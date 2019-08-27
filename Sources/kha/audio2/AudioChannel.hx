package kha.audio2;

import kha.arrays.Float32Array;

class AudioChannel implements kha.audio1.AudioChannel {
	public var data: Float32Array = null;
	var myVolume: Float = 1;
	var myPosition: Int = 0;
	var paused: Bool = false;
	var stopped: Bool = false;
	var looping: Bool = false;

	public function new(looping: Bool) {
		this.looping = looping;
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
