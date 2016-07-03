package kha.capture;

import js.html.audio.AudioProcessingEvent;
import kha.audio2.Buffer;

class Audio {
	private static var input: js.html.audio.MediaStreamAudioSourceNode;
	private static var processingNode: js.html.audio.ScriptProcessorNode;
	private static var buffer: Buffer;
	
	public static var audioCallback: Int->Buffer->Void;
	
	public static function init(initialized: Void->Void, error: Void->Void): Void {
		if (kha.audio2.Audio._context == null) {
			error();
			return;
		}
		
		var getUserMedia = untyped __js__("navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia");
		getUserMedia.call(js.Browser.navigator, {audio: true}, function (stream: Dynamic) {
			input = kha.audio2.Audio._context.createMediaStreamSource(stream);
			
			var bufferSize = 1024 * 2;
			buffer = new Buffer(bufferSize * 4, 2, Std.int(kha.audio2.Audio._context.sampleRate));
			
			processingNode = kha.audio2.Audio._context.createScriptProcessor(bufferSize, 1, 0);
			processingNode.onaudioprocess = function (e: AudioProcessingEvent) {
				if (audioCallback != null) {
					var input1 = e.inputBuffer.getChannelData(0);
					var input2 = e.inputBuffer.getChannelData(0);
					for (i in 0...e.inputBuffer.length) {
						buffer.data.set(buffer.writeLocation, input1[i]);
						buffer.writeLocation += 1;
						buffer.data.set(buffer.writeLocation, input2[i]);
						buffer.writeLocation += 1;
						if (buffer.writeLocation >= buffer.size) {
							buffer.writeLocation = 0;
						}
					}
					audioCallback(e.inputBuffer.length * 2, buffer);
				}
			}
			
			input.connect(processingNode);
			//input.connect(kha.audio2.Audio._context.destination);
			initialized();
		}, function () {
			error();
		});
	}
}
