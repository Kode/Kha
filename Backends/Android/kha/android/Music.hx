package kha.android;

import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import java.lang.Throwable;

class Music implements kha.Music {
	var mp : MediaPlayer;
	static var instance : Music;
	
	public function new(file : AssetFileDescriptor) {
		instance = this;
		try {
			mp = new MediaPlayer();
			mp.setLooping(true);
			mp.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
			mp.prepare();
			mp.start();
		}
		catch (e : Exception) {
			e.printStackTrace();
		}
	}
	
	public function start() : Void {
		mp.start();
	}

	public function stop() : Void {
		mp.stop();
	}
	
	public static function stopit() {
		if (instance != null) instance.stop();
	}
}