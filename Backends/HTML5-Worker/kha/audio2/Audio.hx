package kha.audio2;

import kha.Sound;

class Audio {
	public static var disableGcInteractions = false;
	public static var samplesPerSecond: Int;
	public static var audioCallback: Int->Buffer->Void;

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}
}
