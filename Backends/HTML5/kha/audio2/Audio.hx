package kha.audio2;

import js.html.audio.AudioContext;

class Audio {
	private static var buffer: Buffer;
	
	public static function init() {
		var audioContext = new AudioContext();
		var bufferSize = 4096;
		var processingNode = audioContext.createScriptProcessor(bufferSize, 1, 1);
		processingNode.onaudioprocess = function (e) {
			if (audioCallback != null) {
				audioCallback(bufferSize, buffer);
				var output = e.outputBuffer.getChannelData(0);
				for (i in 0...bufferSize) {
					output[i] = 0; // buffer[i];
				}
			}
			else {
				for (i in 0...bufferSize) {
					output[i] = 0;
				}
			}
		}
		processingNode.connect(audioContext.destination);
		processingNode.start(0);
	}

	public static function shutdown() {
		
	}
	
	public static var audioCallback: Int->Buffer->Void;
}
