package kha.audio1;

import kha.Sound;

extern class Audio {
	public static function play(sound: Sound, loop: Bool = false): AudioChannel;

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel;
}
