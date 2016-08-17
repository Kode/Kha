package kha.audio1;

import kha.Sound;

class Audio {
	
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): AudioChannel {
		return new NodeAudioChannel();
	}
}
