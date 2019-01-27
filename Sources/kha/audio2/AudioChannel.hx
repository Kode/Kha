package kha.audio2;

class AudioChannel implements kha.audio1.AudioChannel {
	public var data: kha.arrays.Float32Array;
	private var myVolume: Float;
	private var myPosition: Int;
	private var paused: Bool = false;
	private var looping: Bool;
	
	public function new(looping: Bool) {
		this.looping = looping;
		myVolume = 1;
		myPosition = 0;
	}
	
	public function nextSamples(samples: kha.arrays.Float32Array, length: Int, sampleRate: Int): Void {
		if (paused) {
			for (i in 0...length) {
				samples[i] = 0;
			}
			return;
		}
		
		var w_ptr = 0;
		var chk_ptr = 0;
		while (w_ptr < length) {
			// compute one chunk to render
			var addressable_data = data.length - myPosition;
			var next_chunk = addressable_data < (length - w_ptr) ? addressable_data : (length - w_ptr);
			while (chk_ptr < next_chunk) {
				samples[w_ptr] = data[myPosition];
				++myPosition;
				++chk_ptr;
				++w_ptr;
			}
			// loop to next chunk if applicable
			if (!looping) break;
			else { 
				chk_ptr = 0;
				if (myPosition >= data.length) {
					myPosition = 0;
				}
			}
		}
		// fill empty
		while (w_ptr < length) {
			samples[w_ptr] = 0;
			++w_ptr;
		}
	}
	
	public function play(): Void {
		paused = false;
		if (finished) {
			myPosition = 0;
			kha.audio1.Audio._playAgain(this);
		}
	}

	public function pause(): Void {
		paused = true;
	}

	public function stop(): Void {
		myPosition = data.length;
	}

	public var length(get, null): Float; // Seconds
	
	private function get_length(): Float {
		return data.length / kha.audio2.Audio.samplesPerSecond / 2; // 44.1 khz in stereo
	}

	public var position(get, set): Float; // Seconds
	
	private function get_position(): Float {
		return myPosition / kha.audio2.Audio.samplesPerSecond / 2;
	}

	private function set_position(value: Float): Float {
		myPosition = Math.round(value * kha.audio2.Audio.samplesPerSecond * 2);
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
		return myPosition >= data.length;
	}
}
