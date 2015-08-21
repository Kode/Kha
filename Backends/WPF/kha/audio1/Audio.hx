package kha.audio1;

class Audio {
	public static function playSound(sound: Sound): kha.audio1.SoundChannel {
		return new WpfSoundChannel(cast(sound, kha.wpf.Sound).filename);
	}
	
	public static function playMusic(music: Music, loop: Bool = false): kha.audio1.MusicChannel {
		return new WpfMusicChannel(cast(music, kha.wpf.Music).filename, loop);
	}	
}
