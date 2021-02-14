package kha.js;

@:keep
class AudioElementAudio {
	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return stream(sound, loop);
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		sound.element.loop = loop;
		var channel = new AEAudioChannel(sound.element, loop);
		channel.play();
		return cast channel;
	}
}
