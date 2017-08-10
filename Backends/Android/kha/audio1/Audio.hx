package kha.audio1;

import android.media.SoundPool;
import android.media.AudioManager;
import kha.android.Sound;

class Audio {
	public static var spSamples = 0;
	public static var spSamplesMax = 32;
	public static var soundpool = new SoundPool(spSamplesMax, AudioManager.STREAM_MUSIC, 0);
	
	public static function play(sound: kha.Sound, loop: Bool = false): kha.audio1.AudioChannel {
		// It is possible to have more than one simultaneously playing instances of one Sound
		// if SoundPool is used.
		// If not, instance can only be streamed once at a time.
		// When attempting to create a second stream it will just restart.
		var androidSound: Sound = cast(sound, Sound);
		if (androidSound.soundId > 0) {
			var loopMode = loop ? -1: 0;
			var sc = new SoundPoolChannel(soundpool, androidSound.soundId, loopMode);
			return sc;
		}
		else {
			try {
			var mc = new MediaPlayerChannel(androidSound, loop);
			return mc;
			}
			catch (e: Dynamic) {
				return null;
			}
		}
		return null;
	}
	
	public static function stream(sound: kha.Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return play(sound, loop);
	}
}
