package kha.audio1;

import android.media.SoundPool;
import kha.android.Sound;

class SoundPoolChannel implements AudioChannel {
	var soundpool: SoundPool;
	var streamId: Int;
	var paused: Bool = false;
	var looping: Bool;
	var running: Bool;
	var startTime: Float;

	public function new(sound: Sound, loopMode: Int) {
		this.soundpool = Audio.soundpool;
		volume = 1;
		length = sound.length;
		looping = (loopMode == -1);
		position = 0;
		this.streamId = soundpool.play(sound.soundId, volume, volume, 1, loopMode, 1);
		running = true;
		startTime = Scheduler.realTime();
	}

	public function play(): Void {
		soundpool.resume(streamId);
		if (!running) {
			running = true;
			startTime = Scheduler.realTime();
		}
	}

	public function pause(): Void {
		soundpool.pause(streamId);
		if (running) {
			running = false;
			position += Scheduler.realTime() - startTime;
			if (looping)
				position %= length;
		}
	}

	public function stop(): Void {
		soundpool.stop(streamId);
		running = false;
		position = 0;
		length = 0;
	}

	@:isVar
	public var length(get, null): Float;

	function get_length(): Float {
		return length;
	}

	@:isVar
	public var position(get, set): Float;

	function get_position(): Float {
		if (!running) {
			return position;
		}
		var pos = position + Scheduler.realTime() - startTime;
		if (looping) {
			return pos % length;
		}
		else if (pos > length) {
			return length;
		}
		return pos;
	}

	function set_position(value: Float): Float {
		return value;
	}

	@:isVar
	public var volume(get, set): Float;

	function get_volume(): Float {
		return volume;
	}

	function set_volume(value: Float): Float {
		soundpool.setVolume(streamId, value, value);
		volume = value;
		return volume;
	}

	public var finished(get, never): Bool;

	function get_finished(): Bool {
		return get_position() == length;
	}
}
