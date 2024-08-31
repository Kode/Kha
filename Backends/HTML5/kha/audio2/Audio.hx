package kha.audio2;

import js.Browser;
import js.Syntax;
import js.html.URL;
import js.html.audio.AudioContext;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.ScriptProcessorNode;
import kha.Sound;
import kha.internal.IntBox;
import kha.js.AEAudioChannel;

class Audio {
	public static var disableGcInteractions = false;
	static var intBox: IntBox = new IntBox(0);
	static var buffer: Buffer;
	@:noCompletion public static var _context: AudioContext;
	static var processingNode: ScriptProcessorNode;

	static function initContext(): Void {
		try {
			_context = new AudioContext();
			return;
		}
		catch (e:Dynamic) {}
		try {
			Syntax.code("this._context = new webkitAudioContext();");
			return;
		}
		catch (e:Dynamic) {}
	}

	@:noCompletion
	public static function _init(): Bool {
		initContext();
		if (_context == null)
			return false;

		Audio.samplesPerSecond = Math.round(_context.sampleRate);
		var bufferSize = 1024 * 2;
		buffer = new Buffer(bufferSize * 4, 2, Std.int(_context.sampleRate));

		processingNode = _context.createScriptProcessor(bufferSize, 0, 2);
		processingNode.onaudioprocess = function(e: AudioProcessingEvent) {
			var output1 = e.outputBuffer.getChannelData(0);
			var output2 = e.outputBuffer.getChannelData(1);
			if (audioCallback != null) {
				intBox.value = e.outputBuffer.length * 2;
				audioCallback(intBox, buffer);
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
		processingNode.connect(_context.destination);
		return true;
	}

	public static var samplesPerSecond: Int;

	public static var audioCallback: (outputBufferLength: IntBox, buffer: Buffer) -> Void;

	static var virtualChannels: Array<VirtualStreamChannel> = [];

	public static function wakeChannels() {
		SystemImpl.mobileAudioPlaying = true;
		for (channel in virtualChannels) {
			channel.wake();
		}
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		// var source = _context.createMediaStreamSource(cast sound.compressedData.getData());
		// source.connect(_context.destination);
		var element = Browser.document.createAudioElement();
		#if kha_debug_html5
		var blob = new js.html.Blob([sound.compressedData.getData()], {type: "audio/ogg"});
		#else
		var blob = new js.html.Blob([sound.compressedData.getData()], {type: "audio/mp4"});
		#end
		element.src = URL.createObjectURL(blob);
		element.loop = loop;
		var channel = new AEAudioChannel(element, loop);

		if (SystemImpl.mobileAudioPlaying) {
			channel.play();
			return channel;
		}
		else {
			var virtualChannel = new VirtualStreamChannel(channel, loop);
			virtualChannels.push(virtualChannel);
			return virtualChannel;
		}
	}
}
