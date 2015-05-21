package kha.audio1;

import kha.Music;
import kha.Sound;

extern class Audio {
	public static function init();
	public static function playSound(sound: Sound);
	public static function stopSound(sound: Sound);
	public static function playMusic(music: Music);
	public static function stopMusic(music: Music);
}
