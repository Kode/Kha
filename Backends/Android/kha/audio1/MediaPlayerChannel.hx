package kha.audio1;
import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import kha.android.Sound;
import android.media.MediaPlayerOnCompletionListener;

class CompListener implements MediaPlayerOnCompletionListener {
	private var mpc: MediaPlayerChannel;
	
	public function new(mpc: MediaPlayerChannel): Void {
		this.mpc = mpc;
	}
	
	public function onCompletion(mp: MediaPlayer): Void {
		mpc.playbackComplete = true;
	}
}

class MediaPlayerChannel implements AudioChannel {
	private var mp: MediaPlayer;
	
	@:noCompletion
	public var playbackComplete: Bool = false;
	
	public function new(sound:Sound, loop:Bool): Void {
		mp = sound.mediaPlayer;
		mp.seekTo(0);
		mp.setLooping(loop);
		volume = 1;
		mp.start();
	}
	
	public function play(): Void {
		mp.start();
	}

	public function pause(): Void {
		mp.pause();
	}

	public function stop(): Void {
		mp.stop();
		mp.release();
	}

	public var length(get, null): Float;

	private function get_length(): Float {
		return mp.getDuration() / 1000;
	}

	public var position(get, null): Float;

	private function get_position(): Float {
		return mp.getCurrentPosition() / 1000;
	}

	@:isVar
	public var volume(get, set): Float;
	
	private function get_volume(): Float {
		return volume;
	}

	private function set_volume(value: Float): Float {
		mp.setVolume(value, value);
		volume = value;
		return value;
	}

	public var finished(get, null): Bool;
	
	private function get_finished(): Bool {
		return playbackComplete;
	}
}
