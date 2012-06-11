package kha.android;

import android.media.SoundPool;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;

class Sound implements kha.Sound {
	static var pool : SoundPool = new SoundPool(4, AudioManager.STREAM_MUSIC, 0);
	var soundid : Int;
	
	public function new(file : AssetFileDescriptor) {
		soundid = pool.load(file, 1);
	}
	
	public function play() : Void {
		pool.play(soundid, 1, 1, 1, 0, 1);
	}

	public function stop() : Void {
		pool.stop(soundid);
	}
}