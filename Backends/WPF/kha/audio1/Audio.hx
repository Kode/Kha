package kha.audio1;

class Audio {
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): kha.audio1.AudioChannel {
		return new WpfAudioChannel(cast(sound, kha.wpf.Sound).filename);
	}
	
	//public static function playMusic(music: Music, loop: Bool = false): kha.audio1.MusicChannel {
	//	return new WpfMusicChannel(cast(music, kha.wpf.Music).filename, loop);
	//}	
}
