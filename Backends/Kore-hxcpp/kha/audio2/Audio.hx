package kha.audio2;

import kha.Sound;
import kha.internal.IntBox;

@:keep
class Audio {
	static var buffer: Buffer;
	static var intBox: IntBox = new IntBox(0);

	@:noCompletion
	public static function _init() {
		var bufferSize = 1024 * 2;
		buffer = new Buffer(bufferSize * 4, 2, 44100);
	}

	@:noCompletion
	public static function _callCallback(samples: Int, sampleRate: Int): Void {
		if (buffer == null)
			return;
		buffer.samplesPerSecond = sampleRate;
		if (audioCallback != null) {
			intBox.value = samples;
			audioCallback(intBox, buffer);
		}
		else {
			for (i in 0...samples) {
				buffer.data.set(buffer.writeLocation, 0);
				buffer.writeLocation += 1;
				if (buffer.writeLocation >= buffer.size) {
					buffer.writeLocation = 0;
				}
			}
		}
	}

	@:noCompletion
	public static function _readSample(): Float {
		if (buffer == null)
			return 0;
		var value = buffer.data.get(buffer.readLocation);
		++buffer.readLocation;
		if (buffer.readLocation >= buffer.size) {
			buffer.readLocation = 0;
		}
		return value;
	}

	public static var disableGcInteractions = false;

	public static var samplesPerSecond: Int;

	public static var audioCallback: IntBox->Buffer->Void;

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}
}
