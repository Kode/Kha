package kha.audio1;

import kha.Music;
import kha.Sound;

class Audio {
	public static function playSound(sound: Sound): kha.audio1.SoundChannel {
		return new JavaSoundChannel(cast(sound, kha.java.Sound));
	}
	
	public static function playMusic(music: Music, loop: Bool = false): kha.audio1.MusicChannel {
		return new JavaMusicChannel(cast(music, kha.java.Music), loop);
	}
}
