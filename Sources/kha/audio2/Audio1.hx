package kha.audio2;

#if cpp
import cpp.vm.Mutex;
#end
import haxe.ds.Vector;
import kha.audio1.MusicChannel;
import kha.audio1.SoundChannel;

class Audio1 {
	private static inline var channelCount: Int = 16;
	private static var soundChannels: Vector<SoundChannel>;
	private static var musicChannels: Vector<MusicChannel>;
	
	private static var internalSoundChannels: Vector<SoundChannel>;
	private static var internalMusicChannels: Vector<MusicChannel>;
	private static var sampleCache1: Vector<Float>;
	private static var sampleCache2: Vector<Float>;
	#if cpp
	private static var mutex: Mutex;
	#end
	
	@:noCompletion
	public static function _init(): Void {
		#if cpp
		mutex = new Mutex();
		#end
		soundChannels = new Vector<SoundChannel>(channelCount);
		musicChannels = new Vector<MusicChannel>(channelCount);
		internalSoundChannels = new Vector<SoundChannel>(channelCount);
		internalMusicChannels = new Vector<MusicChannel>(channelCount);
		sampleCache1 = new Vector<Float>(512);
		sampleCache2 = new Vector<Float>(512);
		Audio.audioCallback = _mix;
	}
	
	private static function _mix(samples: Int, buffer: Buffer): Void {
		if (sampleCache1.length < samples) {
			sampleCache1 = new Vector<Float>(samples);
			sampleCache2 = new Vector<Float>(samples);
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
			internalMusicChannels[i] = musicChannels[i];
		}
		#if cpp
		mutex.release();
		#end

		for (channel in internalSoundChannels) {
			if (channel == null || channel.finished) continue;
			channel.nextSamples(sampleCache1, samples);
			for (i in 0...samples) {
				sampleCache2[i] += sampleCache1[i] * channel.volume;
			}
		}
		for (channel in internalMusicChannels) {
			if (channel == null || channel.finished) continue;
			channel.nextSamples(sampleCache1, samples);
			for (i in 0...samples) {
				sampleCache2[i] += sampleCache1[i] * channel.volume;
			}
		}

		for (i in 0...samples) {
			buffer.data.set(buffer.writeLocation, Math.max(Math.min(sampleCache2[i], 1.0), -1.0));
			buffer.writeLocation += 1;
			if (buffer.writeLocation >= buffer.size) {
				buffer.writeLocation = 0;
			}
		}
	}
	
	public static function playSound(sound: Sound): kha.audio1.SoundChannel {
		#if cpp
		mutex.acquire();
		#end
		var channel: kha.audio1.SoundChannel = null;
		for (i in 0...channelCount) {
			if (soundChannels[i] == null || soundChannels[i].finished) {
				channel = new SoundChannel();
				channel.data = sound.data;
				soundChannels[i] = channel;
				break;
			}
		}
		#if cpp
		mutex.release();
		#end
		return channel;
	}
	
	public static function playMusic(music: Music, loop: Bool = false): kha.audio1.MusicChannel {
		if (music.data == null) return null;
		#if cpp
		mutex.acquire();
		#end
		var channel: kha.audio1.MusicChannel = null;
		for (i in 0...channelCount) {
			if (musicChannels[i] == null || musicChannels[i].finished) {
				channel = new MusicChannel(music.data, loop);
				musicChannels[i] = channel;
				break;
			}
		}
		#if cpp
		mutex.release();
		#end
		return channel;
	}
}
