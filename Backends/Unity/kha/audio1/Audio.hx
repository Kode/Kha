package kha.audio1;

class Audio {
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): kha.audio1.AudioChannel {
		return new UnitySoundChannel(cast(sound, kha.unity.Sound).filename, loop);
	}

	//public static function playMusic(music: Music, loop: Bool = false): kha.audio1.MusicChannel {
	//	return new UnityMusicChannel(cast(music, kha.unity.Music).filename, loop);
	//}
}
