package kha.audio1;

import kha.Music;
import kha.Sound;

extern class Audio {
	public static function playSound(sound: Sound): SoundChannel;
	public static function playMusic(music: Music): MusicChannel;
}
