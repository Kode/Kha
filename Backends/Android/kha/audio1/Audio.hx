package kha.audio1;

class Audio {
	public static function play(sound: Sound, loop: Bool = false): AudioChannel {
		cast(sound, kha.android.Sound).play();
		return null;
	}

	public static function stream(sound: Sound, loop: Bool = false): AudioChannel {
		return null;
	}
}
