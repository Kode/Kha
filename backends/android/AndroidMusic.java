package de.hsharz.game;

import android.content.Context;
import android.media.MediaPlayer;
import de.hsharz.game.engine.Music;

public class AndroidMusic implements Music {
	private MediaPlayer mp;
	private static AndroidMusic instance;
	
	public AndroidMusic(Context context) {
		instance = this;
		try {
	    	mp = MediaPlayer.create(context, R.raw.level1);
	    	mp.setLooping(true);
			//mp.setDataSource("res/raw/jump.wav");
			//mp.prepare();
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
		instance.stop();
	}
}