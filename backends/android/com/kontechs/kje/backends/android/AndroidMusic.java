package com.kontechs.kje.backends.android;

import android.content.Context;
import android.media.MediaPlayer;
import com.kontechs.kje.Music;

public class AndroidMusic implements Music {
	private MediaPlayer mp;
	private static AndroidMusic instance;
	
	public AndroidMusic(Context context) {
		instance = this;
		try {
	    	//mp = MediaPlayer.create(context, R.raw.level1);
	    	//mp.setLooping(true);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void start() {
		//mp.start();
	}

	@Override
	public void stop() {
		//mp.stop();
	}
	
	public static void stopit() {
		instance.stop();
	}

	@Override
	public void update() {
		
	}
}