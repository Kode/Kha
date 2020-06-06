package kha.audio1;

import kha.Sound;

class Audio {
	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return new JavaSoundChannel(cast(sound, kha.java.Sound));
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return new JavaMusicChannel(cast(sound, kha.java.Music), loop);
	}
}
