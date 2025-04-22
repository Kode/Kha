package kha.js;

import js.html.audio.AudioBuffer;
import js.html.audio.AudioBufferSourceNode;
import js.html.audio.ChannelSplitterNode;
import js.html.audio.ChannelMergerNode;
import js.html.audio.GainNode;

class MobileWebAudioChannel implements kha.audio1.AudioChannel {
	var buffer: AudioBuffer;
	var loop: Bool;
	var source: AudioBufferSourceNode;
	var gain: GainNode;
	var startTime: Float;
	var pauseTime: Float;
	var paused: Bool = false;
	var stopped: Bool = false;

	var leftGain: GainNode;
	var rightGain: GainNode;
	var splitter: ChannelSplitterNode;
	var merger: ChannelMergerNode;

	public function new(sound: MobileWebAudioSound, loop: Bool) {
		this.buffer = sound._buffer;
		this.loop = loop;
		createSource();
	}

	function createSource(): Void {
		source = MobileWebAudio._context.createBufferSource();
		source.loop = loop;
		source.buffer = buffer;
		source.onended = function() {
			stopped = true;
		}

		splitter = MobileWebAudio._context.createChannelSplitter(2);
		leftGain = MobileWebAudio._context.createGain();
		rightGain = MobileWebAudio._context.createGain();
		merger = MobileWebAudio._context.createChannelMerger(2);
		gain = MobileWebAudio._context.createGain();

		source.connect(splitter);
		splitter.connect(leftGain, 0);
		splitter.connect(rightGain, 1);
		leftGain.connect(merger, 0, 0);
		rightGain.connect(merger, 0, 1);
		merger.connect(gain);

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
		final wasStopped = paused || stopped;
		pauseTime = MobileWebAudio._context.currentTime - startTime;
		paused = true;
		if (wasStopped)
			return;
		source.stop();
	}

	public function stop(): Void {
		final wasStopped = paused || stopped;
		paused = false;
		stopped = true;
		if (wasStopped)
			return;
		source.stop();
	}

	public var length(get, never): Float; // Seconds

	function get_length(): Float {
		return source.buffer.duration;
	}

	public var position(get, set): Float; // Seconds

	function get_position(): Float {
		if (stopped)
			return length;
		if (paused)
			return pauseTime;
		else
			return MobileWebAudio._context.currentTime - startTime;
	}

	function set_position(value: Float): Float {
		return value;
	}

	public var volume(get, set): Float;

	function get_volume(): Float {
		return gain.gain.value;
	}

	function set_volume(value: Float): Float {
		return gain.gain.value = value;
	}

	public var finished(get, never): Bool;

	function get_finished(): Bool {
		return stopped;
	}
}
