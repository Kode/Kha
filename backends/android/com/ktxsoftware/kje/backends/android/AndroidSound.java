package com.ktxsoftware.kje.backends.android;

import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.media.SoundPool;
import com.ktxsoftware.kje.Sound;

public class AndroidSound implements Sound {
	private static SoundPool pool = new SoundPool(4, AudioManager.STREAM_MUSIC, 0);
	private int soundid;
	
	public AndroidSound(AssetFileDescriptor file) {
		soundid = pool.load(file, 1);
	}
	
	@Override
	public void play() {
		pool.play(soundid, 1, 1, 1, 0, 1);
	}

	@Override
	public void stop() {
		pool.stop(soundid);
	}
}