package kha.audio1;

import kha.Sound;

class Audio {
	/**
	 * Plays a sound immediately.
	 * @param sound
	 * The sound to play
	 * @param loop
	 * Whether or not to automatically loop the sound
	 * @return A channel object that can be used to control the playing sound. Please be a ware that Null is returned when the maximum number of simultaneously played channels was reached.
	 */
	public static function play(sound: Sound, loop: Bool = false): AudioChannel {
		return null;
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}
}
