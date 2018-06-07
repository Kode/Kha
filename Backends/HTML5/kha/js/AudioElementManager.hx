package kha.js;

class AudioElementManager {
	function play() {
		sound.element.loop = loop;
		var channel = new AEAudioChannel(sound.element);
		channel.play();
		return cast channel;
	}
}
