package kha.js;

class AudioElementAudio {
	@:noCompletion
	public static function _compile(): Void { }
	
	public static function playSound(sound: Sound): kha.audio1.SoundChannel {
		sound.element.play();
		return cast new AESoundChannel(sound);
	}

	public static function playMusic(music: Music, loop: Bool = false): kha.audio1.MusicChannel {
		music.element.loop = loop;
		music.element.play();
		return cast new AEMusicChannel(music, loop);
	}
}
