package kha.audio1;

import kha.Sound;

/**
 * Generic representation of management audio.
 */
extern class Audio {
	/**
	 * Play a sound.
	 *
	 * @param sound		The sound we want to play.
	 * @return 			The sound channel of the sound we are playing.
	 */
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): AudioChannel;
}
