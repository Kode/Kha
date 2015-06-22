package kha.android;

import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import java.lang.Exception;
import java.lang.Throwable;

class Video extends kha.Video {
	var mp: MediaPlayer;
	
	public function new(file: AssetFileDescriptor) {
		super();
		try {
			mp = new MediaPlayer();
			mp.setLooping(false);
			mp.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
			mp.prepare();
			mp.start();
		}
		catch (e: Exception) {
			e.printStackTrace();
		}
	}
	
	override public function play(loop: Bool = false): Void {
		//mp.setDisplay(GameView.the().getHolder());
		mp.start();
	}

	override public function stop(): Void {
		mp.stop();
	}
}
