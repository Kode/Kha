package kha.js;

import js.html.audio.AudioContext;

@:keep
class MobileWebAudio {
	@:noCompletion public static var _context: AudioContext;

	@:noCompletion public static function _init(): Void {
		try {
			_context = new AudioContext();
			return;
		}
		catch (e: Dynamic) {
			
		}
		try {
			untyped __js__('this._context = new webkitAudioContext();');
			return;
		}
		catch (e: Dynamic) {
			
		}
	}
	
	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		var channel = new MobileWebAudioChannel(cast sound, loop);
		channel.play();
		return channel; 
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return play(sound, loop);
	}
}
