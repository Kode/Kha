package kha.android;

import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import java.lang.Throwable;

class Music extends kha.Music {
	var mp : MediaPlayer;
	static var instance : Music;
	
	public function new(file : AssetFileDescriptor) {
		super();
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
	
	override public function play() : Void {
		mp.start();
	}

	override public function stop() : Void {
		mp.stop();
	}
	
	public static function stopit() {
		if (instance != null) instance.stop();
	}
}