package kha.audio1;
import android.media.SoundPool;

class SoundPoolChannel implements AudioChannel {
	private var soundpool: SoundPool;
	private var streamId: Int;
	private var paused: Bool = false;
	private var loopMode: Int;
	
	public function new(soundpool: SoundPool, soundId: Int, loopMode: Int) {
		this.soundpool = soundpool;
		volume = 1;
		this.streamId = soundpool.play(soundId, volume, volume, 1, loopMode, 1);
	}
	
	public function play(): Void {
		soundpool.resume(streamId);
	}

	public function pause(): Void {
		soundpool.pause(streamId);
	}

	public function stop(): Void {
		soundpool.stop(streamId);
	}

	public var length(get, null): Float;

	private function get_length(): Float {
		return 0;
	}

	public var position(get, null): Float;

	private function get_position(): Float {
		return 0;
	}

	@:isVar
	public var volume(get, set): Float;
	
	private function get_volume(): Float {
		return volume;
	}

	private function set_volume(value: Float): Float {
		soundpool.setVolume(streamId, value, value);
		volume = value;
		return volume;
	}

	public var finished(get, null): Bool;
	
	private function get_finished(): Bool {
		return false;
	}
}
