package kha.audio1;

import kha.Music;
import kha.Sound;

class Audio {
	public static function playSound(sound: Sound): SoundChannel {
		return new NodeSoundChannel();
	}

	public static function playMusic(music: Music, loop: Bool = false): MusicChannel {
		return new NodeMusicChannel();
	}
}
