package kha.audio2;

import android.media.AudioTrack;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioTrackBuilder;
import android.media.AudioAttributesBuilder;
import android.media.AudioFormatBuilder;
import android.media.AudioTrackOnPlaybackPositionUpdateListener;
import java.NativeArray;
import java.lang.Float;

class Audio {
	private static var audioTrack: AudioTrack;
	public static var buffer: Buffer;
	
	public static var audioCallback: Int->Buffer->Void;
	
	public static function initAudioTrack(): Void {
		var sampleRate = AudioTrack.getNativeOutputSampleRate(AudioTrack.MODE_STREAM);
		var bufferSize = AudioTrack.getMinBufferSize(44100, AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_FLOAT);
		audioTrack = new AudioTrackBuilder()
			.setAudioAttributes(new AudioAttributesBuilder()
				.setUsage(AudioAttributes.USAGE_GAME)
				.setContentType(AudioAttributes.CONTENT_TYPE_UNKNOWN)
				.build())
			.setAudioFormat(new AudioFormatBuilder()
				.setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
				.setSampleRate(sampleRate)
				.setChannelMask(AudioFormat.CHANNEL_OUT_STEREO)
				.build())
			.setBufferSizeInBytes(bufferSize)
			.setTransferMode(AudioTrack.MODE_STREAM)
			.build();
	}
	
	@:noCompletion
	public static function _init(): Bool {
		try {
			initAudioTrack();
			var buffersize = audioTrack.getBufferSizeInFrames();
			buffer = new Buffer(buffersize, 2, 44100);
			
			audioTrack.setPlaybackPositionUpdateListener(new UpdateListener());
			return true;
		}
		catch (e: Dynamic) {
			return false;
		}
	}
	
	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}

	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}
}

private class UpdateListener implements AudioTrackOnPlaybackPositionUpdateListener {
	public function new(): Void {
	}
	
	public function onMarkerReached(track: AudioTrack): Void {
		return null;
	}
	
	public function onPeriodicNotification(track: AudioTrack): Void {
		var notificationPeriod = track.getPositionNotificationPeriod();
		var chunk = new NativeArray<Float>(notificationPeriod * 2);
		
		if (Audio.audioCallback != null) {
			Audio.audioCallback(notificationPeriod, Audio.buffer);
			for (i in 0...notificationPeriod * 2) {
				chunk[i] = Audio.buffer.data.get(Audio.buffer.readLocation);
				Audio.buffer.readLocation += 1;
				if (Audio.buffer.readLocation >= Audio.buffer.size) {
					Audio.buffer.readLocation = 0;
				}
			}
		}
		else {
			for (i in 0...notificationPeriod * 2) {
				chunk[i] = 0;
			}
		}
		track.write(chunk, 0, notificationPeriod * 2, AudioTrack.WRITE_BLOCKING);
	}
}