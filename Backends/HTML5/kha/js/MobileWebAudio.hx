package kha.js;

import js.html.audio.AudioContext;
import js.html.audio.GainNode;

@:keep
class MobileWebAudio {
	@:noCompletion public static var _context: AudioContext;
	@:noCompletion public static var _globalGain: GainNode;

	@:noCompletion public static function mute() {
		if (_globalGain != null) {
			_globalGain.gain.setTargetAtTime(0, _context.currentTime, 0);
		}
	}

	@:noCompletion public static function unmute() {
		if (_globalGain != null) {
			_globalGain.gain.setTargetAtTime(1, _context.currentTime, 0);
		}
	}

	@:noCompletion public static function _init(): Void {
		try {
			_context = new AudioContext();
			_globalGain = _context.createGain();
			_globalGain.connect(_context.destination);
			return;
		}
		catch (e: Dynamic) {

		}
		try {
			untyped __js__('this._context = new webkitAudioContext();');
			_globalGain = _context.createGain();
			_globalGain.connect(_context.destination);
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
