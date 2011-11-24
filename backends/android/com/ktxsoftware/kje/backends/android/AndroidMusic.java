package com.ktxsoftware.kje.backends.android;

import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;

import com.ktxsoftware.kje.Music;

public class AndroidMusic implements Music {
	private MediaPlayer mp;
	private static AndroidMusic instance;
	
	public AndroidMusic(AssetFileDescriptor file) {
		instance = this;
		try {
			mp = new MediaPlayer();
			mp.setLooping(true);
			mp.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
			mp.prepare();
			mp.start();
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void start() {
		mp.start();
	}

	@Override
	public void stop() {
		mp.stop();
	}
	
	public static void stopit() {
		if (instance != null) instance.stop();
	}

	@Override
	public void update() {
		
	}
}