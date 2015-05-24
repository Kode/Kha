package kha.audio2;

import haxe.ds.Vector;
import kha.audio1.MusicChannel;
import kha.audio1.SoundChannel;

class Audio1 {
	private static inline var channelCount: Int = 16;
	private static var soundChannels: Vector<SoundChannel>;
	private static var musicChannels: Vector<MusicChannel>;
	
	@:noCompletion
	public static function _init(): Void {
		soundChannels = new Vector<SoundChannel>(channelCount);
		musicChannels = new Vector<MusicChannel>(channelCount);
		Audio.audioCallback = _mix;
	}
	
	private static function _mix(samples: Int, buffer: Buffer): Void {
		for (i in 0...samples) {
			var value: Float = 0;
			
			for (i in 0...channelCount) {
				if (soundChannels[i] != null) {
					//value += *(s16*)&channels[i].sound->data[channels[i].position] / 32767.0f * channels[i].sound->volume();
					value += soundChannels[i].nextSample() * soundChannels[i].volume;
					value = Math.max(Math.min(value, 1.0), -1.0);
					//channels[i].position += 2;
					if (soundChannels[i].ended()) soundChannels[i] = null;
				}
			}
			for (i in 0...channelCount) {
				if (musicChannels[i] != null) {
					//value += streams[i].stream->nextSample() * streams[i].stream->volume();
					value += musicChannels[i].nextSample() * musicChannels[i].volume;
					value = Math.max(Math.min(value, 1.0), -1.0);
					if (musicChannels[i].ended()) musicChannels[i] = null;
				}
			}
			
			buffer.data.set(buffer.writeLocation, value);
			buffer.writeLocation += 1;
			if (buffer.writeLocation >= buffer.size) {
				buffer.writeLocation = 0;
			}
		}
	}
	
	public static function playSound(sound: Sound): kha.audio1.SoundChannel {
		for (i in 0...channelCount) {
			if (soundChannels[i] == null) {
				var channel = new SoundChannel();
				channel.data = sound.data;
				soundChannels[i] = channel;
				return channel;
			}
		}
		return null;
	}
	
	public static function playMusic(music: Music): kha.audio1.MusicChannel {
		return null;
	}
}
