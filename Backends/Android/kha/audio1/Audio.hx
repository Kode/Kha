package kha.audio1;

import android.media.MediaPlayer;
import android.media.SoundPool;
import android.media.AudioManager;
import kha.android.Sound;
import kha.audio1.SoundChannel;

class Audio {
	public static var soundpool = new SoundPool(32, AudioManager.STREAM_MUSIC, 0);
	
	public static function play(sound: kha.Sound, loop: Bool = false): kha.audio1.AudioChannel {
		var androidSound: Sound = cast(sound, Sound);
		if (androidSound.soundId > 0) {
			var loopMode = loop ? -1: 0;
			var sc = new SoundChannel(soundpool, androidSound.soundId, loopMode);
			return sc;
		}
		return null;
	}
	
	public static function stream(sound: kha.Sound, loop: Bool = false): kha.audio1.AudioChannel {
		try {
			var androidSound: Sound = cast(sound, Sound);
			var mc = new MusicChannel(androidSound, loop);
			return mc;
		}
		catch (e: Dynamic) {
			return null;
		}
	}
}
