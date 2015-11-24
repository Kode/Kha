package kha.js;

class AudioElementAudio {
	@:noCompletion
	public static function _compile(): Void { }
	
	public static function play(sound: Sound, loop: Bool = false, stream: Bool = false): kha.audio1.AudioChannel {
		sound.element.loop = loop;
		sound.element.play();
		return cast new AEAudioChannel(sound);
	}
}
