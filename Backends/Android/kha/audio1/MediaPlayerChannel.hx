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
	private var sound: Sound;
	
	@:noCompletion
	public var playbackComplete: Bool = false;
	
	public function new(sound:Sound, loop:Bool): Void {
		this.sound = sound;
		sound.ownedByMPC = this;
		mp = sound.mediaPlayer;
		mp.seekTo(0);
		mp.setLooping(loop);
		volume = 1;
		mp.setOnCompletionListener(new CompListener(this));
		mp.start();
	}
	
	public function play(): Void {
		try {
			if (!sound.ownedByMPC.playbackComplete) {
				mp.start();
			}
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}

	public function pause(): Void {
		try {
			mp.pause();
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}

	public function stop(): Void {
		try {
			mp.stop();
		}
		catch (e: Dynamic) {
			trace(e);
		}
	}

	public var length(get, null): Float;

	private function get_length(): Float {
		try {
			return mp.getDuration() / 1000;
		}
		catch (e: Dynamic) {
			trace(e);
			return 0;
		}
	}

	public var position(get, null): Float;

	private function get_position(): Float {
		try {
			return mp.getCurrentPosition() / 1000;
		}
		catch (e: Dynamic) {
			trace(e);
			return 0;
		}
	}

	@:isVar
	public var volume(get, set): Float;
	
	private function get_volume(): Float {
		if (sound.ownedByMPC == this) {
			return volume;
		}
		return sound.ownedByMPC.volume;
	}

	private function set_volume(value: Float): Float {
		if (sound.ownedByMPC == this) {
			mp.setVolume(value, value);
			volume = value;
			return value;
		}
		else {
			return sound.ownedByMPC.volume = value;
		}
	}

	public var finished(get, null): Bool;
	
	private function get_finished(): Bool {
		return sound.ownedByMPC.playbackComplete;
	}
}
