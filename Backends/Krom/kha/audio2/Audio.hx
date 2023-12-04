package kha.audio2;

import kha.Sound;
import kha.internal.IntBox;

class Audio {
	public static var disableGcInteractions = false;
	static var intBox: IntBox = new IntBox(0);
	static var buffer: Buffer;

	public static function _init() {
		var bufferSize = 1024 * 2;
		buffer = new Buffer(bufferSize * 4, 2, 44100);
		Audio.samplesPerSecond = 44100;
	}

	public static function _callCallback(samples: Int): Void {
		if (buffer == null)
			return;
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

	public static function _readSample(): Float {
		if (buffer == null)
			return 0;
		var value = buffer.data.get(buffer.readLocation);
		buffer.readLocation += 1;
		if (buffer.readLocation >= buffer.size) {
			buffer.readLocation = 0;
		}
		return value;
	}

	public static var samplesPerSecond: Int;

	public static var audioCallback: IntBox->Buffer->Void;

	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}
}
