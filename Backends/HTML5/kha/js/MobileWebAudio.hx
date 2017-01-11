package kha.js;

import js.html.audio.AudioContext;

@:keep
class MobileWebAudio {
	@:noCompletion public static var _context: AudioContext;

	private static function initContext(): Void {
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

	@:noCompletion
	public static function _compile(): Void { }
	
	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		var source = _context.createBufferSource();
		var mobileSound: MobileWebAudioSound = cast sound;
		source.buffer = mobileSound._buffer;
		source.connect(_context.destination);
		
		source.loop = loop;
		var channel = new MobileWebAudioChannel(source);
		channel.play();
		
		return channel; 
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return play(sound, loop);
	}
}
