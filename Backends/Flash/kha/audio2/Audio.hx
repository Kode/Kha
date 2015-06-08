package kha.audio2;

import flash.events.SampleDataEvent;

class Audio {
	private static var buffer: Buffer;
	private static inline var bufferSize = 4096;
	@:noCompletion
	public static function _init(): Void {
		buffer = new Buffer(bufferSize * 4, 2, 44100);
		
		var sound = new flash.media.Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		sound.play(0, 1, null);
	}
	
	private static function onSampleData(event: SampleDataEvent): Void {
		if (audioCallback != null) {
			audioCallback(bufferSize * 2, buffer);
			for (i in 0...bufferSize) {
				event.data.writeFloat(buffer.data.get(buffer.readLocation));
				buffer.readLocation += 1;
				event.data.writeFloat(buffer.data.get(buffer.readLocation));
				buffer.readLocation += 1;
				if (buffer.readLocation >= buffer.size) {
					buffer.readLocation = 0;
				}
			}
		}
		else {
			for (i in 0...bufferSize) {
				event.data.writeFloat(0);
				event.data.writeFloat(0);
			}
		}
    }
	
	public static var audioCallback: Int->Buffer->Void;
}
