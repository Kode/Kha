package kha.audio1;

import kha.Sound;

class Audio {
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): kha.audio1.AudioChannel {
		return new JavaSoundChannel(cast(sound, kha.java.Sound));
	}
	
	//public static function playMusic(music: Music, loop: Bool = false): kha.audio1.MusicChannel {
	//	return new JavaMusicChannel(cast(music, kha.java.Music), loop);
	//}
}
