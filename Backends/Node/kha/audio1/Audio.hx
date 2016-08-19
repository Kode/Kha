package kha.audio1;

import kha.Sound;

class Audio {
	
	public static function play(sound: Sound, loop: Bool = false): AudioChannel {
		return new NodeAudioChannel();
	}

	public static function stream(sound: Sound, loop: Bool = false): AudioChannel {
		return new NodeAudioChannel();
	}
}
