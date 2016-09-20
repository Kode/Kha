package kha.audio1;

class Audio {
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): kha.audio1.AudioChannel {
		return new WpfAudioChannel(cast(sound, kha.wpf.Sound).filename);
	}
	
	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return new WpfAudioChannel(cast(sound, kha.wpf.Sound).filename);
	}
}
