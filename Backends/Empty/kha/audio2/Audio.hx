package kha.audio2;

import kha.Sound;
import kha.internal.IntBox;

class Audio {
	public static var disableGcInteractions = false;
	public static var samplesPerSecond: Int;
	public static var audioCallback: IntBox->Buffer->Void;

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}
}
