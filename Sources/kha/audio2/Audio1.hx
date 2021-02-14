package kha.audio2;

#if cpp
import sys.thread.Mutex;
#end
import haxe.ds.Vector;

class Audio1 {
	static inline var channelCount: Int = 32;
	static var soundChannels: Vector<AudioChannel>;
	static var streamChannels: Vector<StreamChannel>;

	static var internalSoundChannels: Vector<AudioChannel>;
	static var internalStreamChannels: Vector<StreamChannel>;
	static var sampleCache1: kha.arrays.Float32Array;
	static var sampleCache2: kha.arrays.Float32Array;
	static var lastAllocationCount: Int = 0;

	#if cpp
	static var mutex: Mutex;
	#end

	@:noCompletion
	public static function _init(): Void {
		#if cpp
		mutex = new Mutex();
		#end
		soundChannels = new Vector<AudioChannel>(channelCount);
		streamChannels = new Vector<StreamChannel>(channelCount);
		internalSoundChannels = new Vector<AudioChannel>(channelCount);
		internalStreamChannels = new Vector<StreamChannel>(channelCount);
		sampleCache1 = new kha.arrays.Float32Array(512);
		sampleCache2 = new kha.arrays.Float32Array(512);
		lastAllocationCount = 0;
		Audio.audioCallback = mix;
	}

	static inline function max(a: Float, b: Float): Float {
		return a > b ? a : b;
	}

	static inline function min(a: Float, b: Float): Float {
		return a < b ? a : b;
	}

	public static function mix(samplesBox: kha.internal.IntBox, buffer: Buffer): Void {
		var samples = samplesBox.value;
		if (sampleCache1.length < samples) {
			if (Audio.disableGcInteractions) {
				trace("Unexpected allocation request in audio thread.");
				for (i in 0...samples) {
					buffer.data.set(buffer.writeLocation, 0);
					buffer.writeLocation += 1;
					if (buffer.writeLocation >= buffer.size) {
						buffer.writeLocation = 0;
					}
				}
				lastAllocationCount = 0;
				Audio.disableGcInteractions = false;
				return;
			}
			sampleCache1 = new kha.arrays.Float32Array(samples * 2);
			sampleCache2 = new kha.arrays.Float32Array(samples * 2);
			lastAllocationCount = 0;
		}
		else {
			if (lastAllocationCount > 100) {
				Audio.disableGcInteractions = true;
			}
			else {
				lastAllocationCount += 1;
			}
		}

		for (i in 0...samples) {
			sampleCache2[i] = 0;
		}

		#if cpp
		mutex.acquire();
		#end
		for (i in 0...channelCount) {
			internalSoundChannels[i] = soundChannels[i];
		}
		for (i in 0...channelCount) {
			internalStreamChannels[i] = streamChannels[i];
		}
		#if cpp
		mutex.release();
		#end

		for (channel in internalSoundChannels) {
			if (channel == null || channel.finished)
				continue;
			channel.nextSamples(sampleCache1, samples, buffer.samplesPerSecond);
			for (i in 0...samples) {
				sampleCache2[i] += sampleCache1[i] * channel.volume;
			}
		}
		for (channel in internalStreamChannels) {
			if (channel == null || channel.finished)
				continue;
			channel.nextSamples(sampleCache1, samples, buffer.samplesPerSecond);
			for (i in 0...samples) {
				sampleCache2[i] += sampleCache1[i] * channel.volume;
			}
		}

		for (i in 0...samples) {
			buffer.data.set(buffer.writeLocation, max(min(sampleCache2[i], 1.0), -1.0));
			buffer.writeLocation += 1;
			if (buffer.writeLocation >= buffer.size) {
				buffer.writeLocation = 0;
			}
		}
	}

	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		var channel: kha.audio2.AudioChannel = null;
		if (Audio.samplesPerSecond != sound.sampleRate) {
			channel = new ResamplingAudioChannel(loop, sound.sampleRate);
		}
		else {
			#if sys_ios
			channel = new ResamplingAudioChannel(loop, sound.sampleRate);
			#else
			channel = new AudioChannel(loop);
			#end
		}
		channel.data = sound.uncompressedData;
		var foundChannel = false;

		#if cpp
		mutex.acquire();
		#end
		for (i in 0...channelCount) {
			if (soundChannels[i] == null || soundChannels[i].finished) {
				soundChannels[i] = channel;
				foundChannel = true;
				break;
			}
		}
		#if cpp
		mutex.release();
		#end

		return foundChannel ? channel : null;
	}

	public static function _playAgain(channel: kha.audio2.AudioChannel): Void {
		#if cpp
		mutex.acquire();
		#end
		for (i in 0...channelCount) {
			if (soundChannels[i] == channel) {
				soundChannels[i] = null;
			}
		}
		for (i in 0...channelCount) {
			if (soundChannels[i] == null || soundChannels[i].finished || soundChannels[i] == channel) {
				soundChannels[i] = channel;
				break;
			}
		}
		#if cpp
		mutex.release();
		#end
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		{
			// try to use hardware accelerated audio decoding
			var hardwareChannel = Audio.stream(sound, loop);
			if (hardwareChannel != null)
				return hardwareChannel;
		}

		var channel: StreamChannel = new StreamChannel(sound.compressedData, loop);
		var foundChannel = false;

		#if cpp
		mutex.acquire();
		#end
		for (i in 0...channelCount) {
			if (streamChannels[i] == null || streamChannels[i].finished) {
				streamChannels[i] = channel;
				foundChannel = true;
				break;
			}
		}
		#if cpp
		mutex.release();
		#end

		return foundChannel ? channel : null;
	}
}
