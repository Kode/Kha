package kha.audio2;

import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.ScriptProcessorNode;

class Audio {
	private static var buffer: Buffer;
	private static var audioContext: AudioContext;
	private static var processingNode: ScriptProcessorNode;
	
	@:noCompletion
	public static function _init() {
		var bufferSize = 512;
		
		buffer = new Buffer(bufferSize * 4, 2, 44100);
		
		audioContext = new AudioContext();
		processingNode = audioContext.createScriptProcessor(bufferSize, 1, 1);
		processingNode.onaudioprocess = function (e) {
			var output = e.outputBuffer.getChannelData(0);
			if (audioCallback != null) {
				audioCallback(bufferSize * 2, buffer);
				for (i in 0...bufferSize) {
					output[i] = buffer.data.get(buffer.readLocation);
					buffer.readLocation += 2;
					if (buffer.readLocation >= buffer.size) {
						buffer.readLocation = 0;
					}
				}
			}
			else {
				for (i in 0...bufferSize) {
					output[i] = 0;
				}
			}
		}
		processingNode.connect(audioContext.destination);
	}

	public static var audioCallback: Int->Buffer->Void;
}
