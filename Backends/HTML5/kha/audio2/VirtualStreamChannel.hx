package kha.audio2;

import kha.js.AEAudioChannel;
import kha.audio1.AudioChannel;

enum PlayMode {
	Stopped;
	Paused;
	Playing;
}

class VirtualStreamChannel implements kha.audio1.AudioChannel {
	var aeChannel: AEAudioChannel;
	var mode = PlayMode.Playing;
	var lastTickTime: Float;
	var lastPosition: Float;
	var looping: Bool;
	
	public function new(aeChannel: AEAudioChannel, looping: Bool) {
		this.aeChannel = aeChannel;
		this.looping = looping;
		lastTickTime = Scheduler.realTime();
		lastPosition = 0;
	}

	public function wake(): Void {
		updatePosition();
		aeChannel.position = lastPosition;
		aeChannel.play();
	}

	function updatePosition(): Void {
		var now = Scheduler.realTime();
		switch (mode) {
			case Stopped:
				lastPosition = 0;
			case Paused:
				// nothing
			case Playing:
				lastPosition += now - lastTickTime;
				while (lastPosition > length) {
					lastPosition -= length;
				}
		}
		lastTickTime = now;
	}
	
	public function play(): Void {
		if (SystemImpl.mobileAudioPlaying) {
			aeChannel.play();
		}
		else {
			updatePosition();
			mode = Playing;
		}
	}
	
	public function pause(): Void {
		if (SystemImpl.mobileAudioPlaying) {
			aeChannel.pause();
		}
		else {
			updatePosition();
			mode = Paused;
		}
	}

	public function stop(): Void {
		if (SystemImpl.mobileAudioPlaying) {
			aeChannel.stop();
		}
		else {
			updatePosition();
			mode = Stopped;
		}
	}

	public var length(get, null): Float; // Seconds
	
	function get_length(): Float {
		return aeChannel.length;
	}

	public var position(get, set): Float; // Seconds
	
	function get_position(): Float {
		if (SystemImpl.mobileAudioPlaying) {
			return aeChannel.position;
		}
		else {
			updatePosition();
			return lastPosition;
		}
	}

	function set_position(value: Float): Float {
		if (SystemImpl.mobileAudioPlaying) {
			return aeChannel.position = value;
		}
		else {
			updatePosition();
			return lastPosition = value;
		}
	}

	public var volume(get, set): Float;

	function get_volume(): Float {
		return aeChannel.volume;
	}

	function set_volume(value: Float): Float {
		return aeChannel.volume = value;
	}

	public var finished(get, null): Bool;

	function get_finished(): Bool {
		if (SystemImpl.mobileAudioPlaying) {
			return aeChannel.finished;
		}
		else {
			return mode == Stopped || (!looping && position >= length);
		}
	}
}
