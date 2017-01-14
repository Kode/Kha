package kha.js;

import js.html.audio.AudioBuffer;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.GainNode;

class MobileWebAudioChannel implements kha.audio1.AudioChannel {
	private var buffer: AudioBuffer;
	private var loop: Bool;
	private var source: AudioBufferSourceNode;
	private var gain: GainNode;
	private var startTime: Float;
	private var pauseTime: Float;
	private var paused: Bool = false;
	private var stopped: Bool = false;

	public function new(sound: MobileWebAudioSound, loop: Bool) {
		this.buffer = sound._buffer;
		this.loop = loop;
		createSource();
	}

	private function createSource(): Void {
		source = MobileWebAudio._context.createBufferSource();
		source.loop = loop;
		source.buffer = buffer;
		source.onended = function () {
			stopped = true;
		}
		gain = MobileWebAudio._context.createGain();
		source.connect(gain);
		gain.connect(MobileWebAudio._context.destination);
	}
	
	public function play(): Void {
		if (paused || stopped) {
			createSource();
		}
		stopped = false;
		if (paused) {
			paused = false;
			startTime = MobileWebAudio._context.currentTime - pauseTime;
			source.start(0, pauseTime);
		}
		else {
			startTime = MobileWebAudio._context.currentTime;
			source.start();
		}
	}

	public function pause(): Void {
		pauseTime = MobileWebAudio._context.currentTime - startTime;
		paused = true;
		source.stop();
	}

	public function stop(): Void {
		paused = false;
		stopped = true;
		source.stop();
	}

	public var length(get, null): Float; // Seconds
	
	private function get_length(): Float {
		return source.buffer.duration;
	}

	public var position(get, null): Float; // Seconds
	
	private function get_position(): Float {
		if (stopped) return length;
		if (paused) return pauseTime;
		else return MobileWebAudio._context.currentTime - startTime;
	}

	public var volume(get, set): Float;

	private function get_volume(): Float {
		return gain.gain.value;
	}

	private function set_volume(value: Float): Float {
		return gain.gain.value = value;
	}

	public var finished(get, null): Bool;

	private function get_finished(): Bool {
		return stopped;
	}
}
