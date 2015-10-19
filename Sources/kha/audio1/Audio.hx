package kha.audio1;

import kha.Music;
import kha.Sound;

/**
 * Generic representation of management audio.
 */
extern class Audio {
	/**
	 * Play a sound.
	 *
	 * @param sound		The sound we want to play.
	 * @param sound		The volume of the sound to play.
	 * @return 			The sound channel of the sound we are playing.
	 */
	public static function playSound(sound: Sound, volume: Float = 1.0): SoundChannel;
	
	/**
	 * Play some music.
	 *
	 * @param music		The music we want to play.
	 * @param loop		If we want the music to loop, default = false.
	 * @return 			The music channel of the music we are playing.
	 */
	public static function playMusic(music: Music, loop: Bool = false): MusicChannel;
}
