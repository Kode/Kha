package kha.audio2;

import kha.arrays.Float32Array;

class ResamplingAudioChannel extends AudioChannel {
	public var sampleRate: Int;

	public function new(looping: Bool, sampleRate: Int) {
		super(looping);
		this.sampleRate = sampleRate;
	}
	
	public override function nextSamples(requestedSamples: Float32Array, requestedLength: Int, sampleRate: Int): Void {
		if (paused || stopped) {
			for (i in 0...requestedLength) {
				requestedSamples[i] = 0;
			}
			return;
		}
		
		var requestedSamplesIndex = 0;
		while (requestedSamplesIndex < requestedLength) {
			for (i in 0...min(sampleLength(sampleRate) - myPosition, requestedLength - requestedSamplesIndex)) {
				requestedSamples[requestedSamplesIndex++] = sample(myPosition++, sampleRate);
			}

			if (myPosition >= sampleLength(sampleRate)) {
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

	inline function sample(position: Int, sampleRate: Int): Float {
		var even = position % 2 == 0;
		var factor = this.sampleRate / sampleRate;

		if (even) {
			position = Std.int(position / 2);
			var pos = factor * position;
			var pos1 = Math.floor(pos);
			var pos2 = Math.floor(pos + 1);
			pos1 *= 2;
			pos2 *= 2;

			var minimum = 0;
			var maximum = data.length - 1;
			maximum = maximum % 2 == 0 ? maximum : maximum - 1;

			var a = (pos1 < minimum || pos1 > maximum) ? 0 : data[pos1];
			var b = (pos2 < minimum || pos2 > maximum) ? 0 : data[pos2];
			return lerp(a, b, pos - Math.floor(pos));
		}
		else {
			position = Std.int(position / 2);
			var pos = factor * position;
			var pos1 = Math.floor(pos);
			var pos2 = Math.floor(pos + 1);
			pos1 = pos1 * 2 + 1;
			pos2 = pos2 * 2 + 1;

			var minimum = 1;
			var maximum = data.length - 1;
			maximum = maximum % 2 != 0 ? maximum : maximum - 1;

			var a = (pos1 < minimum || pos1 > maximum) ? 0 : data[pos1];
			var b = (pos2 < minimum || pos2 > maximum) ? 0 : data[pos2];
			return lerp(a, b, pos - Math.floor(pos));
		}
	}

	inline function lerp(v0: Float, v1: Float, t: Float) {
		return (1 - t) * v0 + t * v1;
	}
	
	inline function sampleLength(sampleRate: Int): Int {
		var value = Math.ceil(data.length * (sampleRate / this.sampleRate));
		return value % 2 == 0 ? value : value + 1;
	}

	public override function play(): Void {
		paused = false;
		stopped = false;
		kha.audio1.Audio._playAgain(this);
	}

	public override function pause(): Void {
		paused = true;
	}

	public override function stop(): Void {
		myPosition = 0;
		stopped = true;
	}
	
	override function get_length(): Float {
		return data.length / this.sampleRate / 2; // 44.1 khz in stereo
	}

	override function get_position(): Float {
		return myPosition / this.sampleRate / 2;
	}

	override function set_position(value: Float): Float {
		myPosition = Math.round(value * this.sampleRate * 2);
		myPosition = max(min(myPosition, sampleLength(kha.audio2.Audio.samplesPerSecond)), 0);
		return value;
	}
	
	override function get_volume(): Float {
		return myVolume;
	}

	override function set_volume(value: Float): Float {
		return myVolume = value;
	}
	
	override function get_finished(): Bool {
		return stopped;
	}

	static inline function max(a: Int, b: Int) {
		return a > b ? a : b;
	}

	static inline function min(a: Int, b: Int) {
		return a < b ? a : b;
	}
}
