package kha.audio1;

class Audio {
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): AudioChannel {
		cast(sound, kha.android.Sound).play();
		return null;
	}

	/*public static function playMusic(music: Music, loop: Bool = false): MusicChannel {
		cast(music, kha.android.Music).play(loop);
		return null;
	}*/
}
