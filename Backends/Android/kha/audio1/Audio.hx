package kha.audio1;

import android.media.MediaPlayer;
import android.media.SoundPool;
import android.media.AudioManager;
import kha.android.Sound;
import kha.audio1.SoundChannel;

class Audio {
	public static var soundpool = new SoundPool(32, AudioManager.STREAM_MUSIC, 0);
	
	public static function play(sound: kha.Sound, loop: Bool = false): kha.audio1.AudioChannel {
		// It is possible to have more than one simultaneously playing instances of one Sound,
		// but play() will return null if the sound asset is bigger than 1MB.
		var androidSound: Sound = cast(sound, Sound);
		if (androidSound.soundId > 0) {
			var loopMode = loop ? -1: 0;
			var sc = new SoundChannel(soundpool, androidSound.soundId, loopMode);
			return sc;
		}
		return null;
	}
	
	public static function stream(sound: kha.Sound, loop: Bool = false): kha.audio1.AudioChannel {
		// Every Sound instance can only be streamed once at a time,
		// when attempting to create a second stream it will just restart.
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
