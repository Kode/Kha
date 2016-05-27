package kha.audio2;

import haxe.io.Float32Array;
import js.Browser;
import js.html.Document;
import js.html.URL;
import js.html.Window;
import js.html.audio.AudioBuffer;
import js.html.audio.AudioContext;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.ConvolverNode;
import js.html.audio.GainNode;
import js.html.audio.ScriptProcessorNode;
import kha.Assets;
import kha.Blob;
import kha.Scheduler;
import kha.audio2.hrtf.Container;
import kha.audio2.hrtf.Panner;
import kha.audio2.hrtf.Utils;
import kha.js.AEAudioChannel;
import kha.js.WebAudioSound;
import kha.Sound;
import kha.math.Vector3;

class AudioTrack {
	public var position: Vector3; // used if speaker != -1
	public var speaker: Int = -1;
	
	private var buffer: Buffer;
	private var processingNode: ScriptProcessorNode;
	private var panner: Panner;
	
	public function new() {
		var bufferSize = 1024 * 2;
		buffer = new Buffer(bufferSize * 4, 2, Std.int(Audio._context.sampleRate));
		
		processingNode = Audio._context.createScriptProcessor(bufferSize, 0, 1);
		processingNode.onaudioprocess = function (e: AudioProcessingEvent) {
			if (callback == null) {
				var output: Array<js.html.Float32Array> = [];
				for (channel in 0...e.outputBuffer.numberOfChannels) {
					output[channel] = e.outputBuffer.getChannelData(channel);
				}

				for (i in 0...e.outputBuffer.length) {
					for (channel in 0...e.outputBuffer.numberOfChannels) {
						output[channel][i] = 0;
					}
				}
				return;
			}
			
			var position: Vector3;
			if (speaker >= 0) {
				position = Audio.speakerPositions[speaker];
			}
			else {
				position = this.position;
			}

			if (Audio.headphones) {
				var cords = Utils.cartesianToInteraural(position.x, position.y, position.z);
				panner.update(cords.azm, cords.elv);
				
				var output = e.outputBuffer.getChannelData(0);
				
				callback(e.outputBuffer.length, buffer);
				for (i in 0...e.outputBuffer.length) {
					output[0] = buffer.data.get(buffer.readLocation);
					buffer.readLocation += 1;
					buffer.readLocation += 1; // ignore stereo
					if (buffer.readLocation >= buffer.size) {
						buffer.readLocation = 0;
					}
				}
			}
			else {
				var output: Array<js.html.Float32Array> = [];
				for (channel in 0...e.outputBuffer.numberOfChannels) {
					output[channel] = e.outputBuffer.getChannelData(channel);
				}
				
				var closestLeftIndex = -1;
				var closestLeft: Float = Math.NEGATIVE_INFINITY;
				var closestLeftZ: Float = Math.NEGATIVE_INFINITY;
				var closestRightIndex = -1;
				var closestRight: Float = Math.POSITIVE_INFINITY;
				var closestRightZ: Float = Math.POSITIVE_INFINITY;
				for (channel in 0...e.outputBuffer.numberOfChannels) {
					var pos = Audio.speakerPositions[channel];
					if (pos.x < position.x && (pos.x > closestLeft || (pos.x == closestLeft && Math.abs(position.z - pos.z) < Math.abs(position.z - closestLeftZ)))) {
						closestLeft = pos.x;
						closestLeftZ = pos.z;
						closestLeftIndex = channel;
					}
					if (pos.x > position.x && (pos.x < closestRight || (pos.x == closestRight && Math.abs(position.z - pos.z) < Math.abs(position.z - closestRightZ)))) {
						closestRight = pos.x;
						closestRightZ = pos.z;
						closestRightIndex = channel;
					}
				}
				
				var closestFrontIndex = -1;
				var closestFront: Float = Math.POSITIVE_INFINITY;
				var closestFrontX: Float = Math.POSITIVE_INFINITY;
				var closestBackIndex = -1;
				var closestBack: Float = Math.NEGATIVE_INFINITY;
				var closestBackX: Float = Math.NEGATIVE_INFINITY;
				for (channel in 0...e.outputBuffer.numberOfChannels) {
					var pos = Audio.speakerPositions[channel];
					if (pos.z > position.z && (pos.z < closestFront || (pos.z == closestFront && Math.abs(position.x - pos.x) < Math.abs(position.x - closestFrontX)))) {
						closestFront = pos.z;
						closestFrontX = pos.x;
						closestFrontIndex = channel;
					}
					if (pos.z < position.z && (pos.z > closestBack || (pos.z == closestBack && Math.abs(position.x - pos.x) < Math.abs(position.x - closestBackX)))) {
						closestBack = pos.z;
						closestBackX = pos.x;
						closestBackIndex = channel;
					}
				}
				
				var xdistance = closestRight - closestLeft;
				var left = (position.x - closestRight) / xdistance;
				var right = (closestRight - position.x) / xdistance;
				
				var zdistance = closestFront - closestBack;
				var front = (position.z - closestBack) / zdistance;
				var back = (closestFront - position.z) / zdistance;
				
				left /= 2;
				right /= 2;
				front /= 2;
				back /= 2;
				
				callback(e.outputBuffer.length, buffer);
				for (channel in 0...e.outputBuffer.numberOfChannels) {
					for (i in 0...e.outputBuffer.length) {
						output[channel][i] = 0;
					}
				}
				for (i in 0...e.outputBuffer.length) {
					output[closestLeftIndex][i] = left * buffer.data.get(buffer.readLocation);
					output[closestRightIndex][i] = right * buffer.data.get(buffer.readLocation);
					output[closestFrontIndex][i] = front * buffer.data.get(buffer.readLocation);
					output[closestBackIndex][i] = back * buffer.data.get(buffer.readLocation);
					buffer.readLocation += 1;
					buffer.readLocation += 1; // ignore stereo
					if (buffer.readLocation >= buffer.size) {
						buffer.readLocation = 0;
					}
				}
			}
		}
		
		if (Audio.headphones) {
			var gain = Audio._context.createGain();
			gain.gain.value = 0.3;
			processingNode.connect(gain);
			panner = new Panner(Audio._context, gain, Audio._hrtfContainer);
			panner.connect(Audio._context.destination);
		}
		else processingNode.connect(Audio._context.destination);
	}
	
	public static var callback: Int->Buffer->Void;
}

class Audio {
	public static var headphones: Bool = true;
	public static var speakerPositions: Array<Vector3>;
	private static var buffer: Buffer;
	@:noCompletion public static var _context: AudioContext;
	@:noCompletion public static var _hrtfContainer: Container;
	private static var processingNode: ScriptProcessorNode;
	
	public static function _initHrtf(hrir: Blob): Void { //, sourceNode: Dynamic): Void {
		_hrtfContainer = new Container();
		_hrtfContainer.loadHrir(hrir);
		/*var gain = _context.createGain();
		gain.gain.value = 0.3;
		sourceNode.connect(gain);
		var panner = new Panner(_context, gain, _hrtfContainer);
		panner.connect(_context.destination);
		
		var t = 0.0;
		var x, y, z;
		Scheduler.addTimeTask(function () {
			x = Math.sin(t);
			y = Math.cos(t);
			z = 0;
			t += 0.05;
			var cords = Utils.cartesianToInteraural(x, y, z);
			panner.update(cords.azm, cords.elv);			
		}, 0, 0.05);*/
	}
	
	private static function initContext(): Void {
		speakerPositions = [new Vector3( -1, 0, 1), new Vector3(1, 0, 1), new Vector3( -1, 0, -1), new Vector3(1, 0, -1), new Vector3(0, 0, 1)];

		try {
			_context = new AudioContext();
			return;
		}
		catch (e: Dynamic) {
			
		}
		try {
			untyped __js__('this._context = new webkitAudioContext();');
			return;
		}
		catch (e: Dynamic) {
			
		}
	}
	
	@:noCompletion
	public static function _init(): Bool {
		#if sys_debug_html5
		return false;
		#end
		
		initContext();
		if (_context == null) return false;
		
		var bufferSize = 1024 * 2;
		buffer = new Buffer(bufferSize * 4, 2, Std.int(_context.sampleRate));
		
		processingNode = _context.createScriptProcessor(bufferSize, 0, 2);
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
		//processingNode.connect(_context.destination);
		
		Assets.blobs.kemar_L_binLoad(function () {
			_initHrtf(Assets.blobs.kemar_L_bin);// , processingNode);
		});
		
		return true;
	}

	public static var audioCallback: Int->Buffer->Void;
	
	private static var tracks: Array<AudioTrack> = [];
	
	public static function addTrack(track: AudioTrack): Void {
		tracks.push(track);
	}
	
	public static function removeTrack(track: AudioTrack): Void {
		tracks.remove(track);
	}
	
	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		//var source = _context.createMediaStreamSource(cast sound.compressedData.getData());
		//source.connect(_context.destination);
		var element = Browser.document.createAudioElement();
		var blob = new js.html.Blob([sound.compressedData.getData()], {type: "audio/mp4"});
		element.src = URL.createObjectURL(blob);
		element.loop = loop;
		var channel = new AEAudioChannel(element);
		channel.play();
		return channel;
	}
}
