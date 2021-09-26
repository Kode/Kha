package kha.audio2;

/*
	#if cpp
	import sys.thread.Mutex;
	#end
	import haxe.ds.Vector;

	class Audio1 {
	private static inline var channelCount: Int = 32;
	private static var soundChannels: Vector<AudioChannel>;
	private static var streamChannels: Vector<StreamChannel>;

	private static var internalSoundChannels: Vector<AudioChannel>;
	private static var internalStreamChannels: Vector<StreamChannel>;
	private static var sampleCache1: kha.arrays.Float32Array;
	private static var sampleCache2: kha.arrays.Float32Array;
	private static var lastAllocationCount: Int = 0;

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

	private static inline function max(a: Float, b: Float): Float {
		return a > b ? a : b;
	}

	private static inline function min(a: Float, b: Float): Float {
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
			if (channel == null || channel.finished) continue;
			channel.nextSamples(sampleCache1, samples, buffer.samplesPerSecond);
			for (i in 0...samples) {
				sampleCache2[i] += sampleCache1[i] * channel.volume;
			}
		}
		for (channel in internalStreamChannels) {
			if (channel == null || channel.finished) continue;
			channel.nextSamples(sampleCache1, samples, buffer.samplesPerSecond);
			for (i in 0...samples) {
				sampleCache2[i] += sampleCache1[i] * channel.volume;
			}
		}

		dynamicCompressor(samples, sampleCache2);

		for (i in 0...samples) {
			buffer.data.set(buffer.writeLocation, max(min(sampleCache2[i], 1.0), -1.0));
			buffer.writeLocation += 1;
			if (buffer.writeLocation >= buffer.size) {
				buffer.writeLocation = 0;
			}
		}
	}

	static var compressedLast = false;

	static function dynamicCompressor(samples: Int, cache: kha.arrays.Float32Array) {
		var sum = 0.0;
		for (i in 0...samples) {
			sum += cache[i];
		}
		sum /= samples;
		if (sum > 0.9) {
			compressedLast = true;
			for (i in 0...samples) {
				if (cache[i] > 0.9) {
					cache[i] = 0.9 + (cache[i] - 0.9) * 0.2;
				}
			}
		}
		else if (compressedLast) {
			compressedLast = false;
			for (i in 0...samples) {
				if (cache[i] > 0.9) {
					cache[i] = 0.9 + (cache[i] - 0.9) * lerp(i, samples);
				}
			}
		}
	}

	static inline function lerp(index: Int, samples: Int) {
		final start = 0.2;
		final end = 1.0;
		return start + (index / samples) * (end - start);
	}

	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		var channel: kha.audio2.AudioChannel = null;
		if (Audio.samplesPerSecond != sound.sampleRate) {
			channel = new ResamplingAudioChannel(loop, sound.sampleRate);
		}
		else {
			channel = new AudioChannel(loop);
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
			if (hardwareChannel != null) return hardwareChannel;
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
 */
@:cppFileCode('
#include <kinc/pch.h>
#include <kinc/audio2/audio.h>
#include <khalib/audio1.h>
#include <math.h>

static int maxi(int a, int b) { return a > b ? a : b; }
static int mini(int a, int b) { return a < b ? a : b; }
static double maxd(double a, double b) { return a > b ? a : b; }
static double mind(double a, double b) { return a < b ? a : b; }
static double roundd(double value) { return floor(value + 0.5); }
static int sampleLength(AudioChannel *channel, int sampleRate) {
	int value = (int)ceilf((float)channel->data_length * ((float)sampleRate / (float)channel->sample_rate));
	return value % 2 == 0 ? value : value + 1;
}
')
@:headerCode('struct AudioChannel;')
@:headerClassCode("AudioChannel *channel;")
class KincAudioChannel implements kha.audio1.AudioChannel {
	public function new() {
		cpp.vm.Gc.setFinalizer(this, cpp.Function.fromStaticFunction(finalize));
	}

	@:functionCode('AudioChannel_dec(channel->channel);')
	@:void static function finalize(channel: KincAudioChannel): Void {}

	@:functionCode('
		channel = AudioChannel_create((rc_sound*)data);
		channel->data_length = size;
		float volume = 1.0f;
		KINC_ATOMIC_EXCHANGE_FLOAT(&channel->volume, volume);
		float playback_rate = 1.0f;
		KINC_ATOMIC_EXCHANGE_FLOAT(&channel->playback_rate, playback_rate);
		KINC_ATOMIC_EXCHANGE_32(&channel->paused, false);
		KINC_ATOMIC_EXCHANGE_32(&channel->stopped, false);
		channel->looping = looping;
		channel->sample_rate = sampleRate;
		KINC_ATOMIC_EXCHANGE_32(&channel->position , 0);
	')
	public function allocate(data: cpp.Star<cpp.Void>, size: Int, sampleRate: Int, looping: Bool): Void {}

	@:functionCode('KINC_ATOMIC_EXCHANGE_32(&channel->paused, false); KINC_ATOMIC_EXCHANGE_32(&channel->stopped, false); AudioChannel_playAgain(channel);')
	public function play(): Void {}

	@:functionCode('KINC_ATOMIC_EXCHANGE_32(&channel->paused, true);')
	public function pause(): Void {}

	@:functionCode('KINC_ATOMIC_EXCHANGE_32(&channel->stopped, true); KINC_ATOMIC_EXCHANGE_32(&channel->position, 0);')
	public function stop(): Void {}

	public var length(get, null): Float; // Seconds

	@:functionCode('return (double)channel->data_length / (double)channel->sample_rate / 2.0;') // 44.1 khz in stereo
	function get_length(): Float {
		return 0;
	}

	public var position(get, set): Float; // Seconds

	@:functionCode('return (double)channel->position / (double)kinc_a2_samples_per_second / 2.0;')
	function get_position(): Float {
		return 0;
	}

	@:functionCode('
		int pos = (int)roundd(value * (double)kinc_a2_samples_per_second * 2.0);
		pos = pos % 2 == 0 ? pos : pos + 1;
		KINC_ATOMIC_EXCHANGE_32(&channel->position, maxi(mini(pos, sampleLength(channel, kinc_a2_samples_per_second)), 0));
		return value;
	')
	function set_position(value: Float): Float {
		return 0;
	}

	public var volume(get, set): Float;

	@:functionCode('return channel->volume;')
	function get_volume(): Float {
		return 0;
	}

	@:functionCode('
		float value = (float)value_;
		if (channel->volume == 0.0f && value != 0.0f) {
			KINC_ATOMIC_EXCHANGE_FLOAT(&channel->volume, value);
			AudioChannel_playAgain(channel);
		}
		else {
			KINC_ATOMIC_EXCHANGE_FLOAT(&channel->volume, value);
		}
		return value_;
	')
	function set_volume(value_: Float): Float {
		return 0;
	}

	public var finished(get, null): Bool;

	@:functionCode('return channel->stopped;')
	function get_finished(): Bool {
		return false;
	}

	public var playbackRate(get, set): Float;

	@:functionCode('return channel->playback_rate;')
	function get_playbackRate(): Float {
		return 1;
	}

	@:functionCode('float value = (float)value_; KINC_ATOMIC_EXCHANGE_FLOAT(&channel->playback_rate, value); return value_;')
	function set_playbackRate(value_: Float): Float {
		return 1;
	}
}

@:cppFileCode('
#include <kinc/pch.h>
#include <kinc/audio2/audio.h>
#include <khalib/audio1.h>
')
class Audio1 {
	@:noCompletion
	@:functionCode('Audio_init();')
	public static function _init(): Void {}

	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		var channel = new KincAudioChannel();
		channel.allocate(sound.uncompressedData, sound.uncompressedDataSize, sound.sampleRate, loop);
		play2(channel, loop);
		return channel;
	}

	@:functionCode('Audio_play(channel->channel, loop);')
	static function play2(channel: KincAudioChannel, loop: Bool) {}

	// public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel;
}
