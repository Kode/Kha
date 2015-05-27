package kha.audio2;

import js.Browser;
import js.html.audio.AudioContext;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.ScriptProcessorNode;

class Audio {
	private static var buffer: Buffer;
	private static var audioContext: AudioContext;
	private static var processingNode: ScriptProcessorNode;
	
	@:noCompletion
	public static function _init() {
		var bufferSize = 1024 * 2;
		
		buffer = new Buffer(bufferSize * 4, 2, 44100);
		
		audioContext = new AudioContext();
		processingNode = audioContext.createScriptProcessor(bufferSize, 0, 2);
		processingNode.onaudioprocess = function (e: AudioProcessingEvent) {
			var output1 = e.outputBuffer.getChannelData(0);
			var output2 = e.outputBuffer.getChannelData(1);
			if (audioCallback != null) {
				audioCallback(e.outputBuffer.length * 2, buffer);
				for (i in 0...e.outputBuffer.length) {
					output1[i] = buffer.data.get(buffer.readLocation);
					buffer.readLocation += 1;
					output2[i] = buffer.data.get(buffer.readLocation);
					buffer.readLocation += 1;
					if (buffer.readLocation >= buffer.size) {
						buffer.readLocation = 0;
					}
				}
			}
			else {
				for (i in 0...e.outputBuffer.length) {
					output1[i] = 0;
					output2[i] = 0;
				}
			}
		}
		processingNode.connect(audioContext.destination);
	}

	public static var audioCallback: Int->Buffer->Void;
}
