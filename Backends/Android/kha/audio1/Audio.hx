package kha.audio1;

class Audio {
	public static function playSound(sound: Sound): SoundChannel {
		sound.play();
		return null;
	}

	public static function playMusic(music: Music, loop: Bool = false): MusicChannel {
		music.play(loop);
		return null;
	}
}
