package kha.audio2;

import java.NativeArray;
import android.media.AudioTrack;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioTrackBuilder;
import android.media.AudioAttributesBuilder;
import android.media.AudioFormatBuilder;
import android.media.AudioTrackOnPlaybackPositionUpdateListener;

class Audio {
	private static var audioTrack: AudioTrack;
	private static var listener: UpdateListener;
	public static var buffer: Buffer;
	
	public static var audioCallback: Int->Buffer->Void;
	
	public static function initAudioTrack(): Void {
		var sampleRate = 44100; // AudioTrack.getNativeOutputSampleRate(AudioTrack.MODE_STREAM);
		var bufferSize = AudioTrack.getMinBufferSize(44100, AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_FLOAT) * 2;
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
			audioTrack.setPositionNotificationPeriod(Math.ceil(buffersize / 2));
			listener = new UpdateListener();
			audioTrack.setPlaybackPositionUpdateListener(listener);
			// prime the AudioTrack buffer to ensure playback
			var zeros = new NativeArray<Single>(buffersize * 2);
			for (i in 0...buffersize) {
				zeros[2 * i + 0] = 0.0;
				zeros[2 * i + 1] = 0.0;
			}
			audioTrack.write(zeros, 0, buffersize * 2, AudioTrack.WRITE_BLOCKING);
			
			audioTrack.play();
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
		var chunk = new NativeArray<Single>(notificationPeriod * 2);
		
		if (Audio.audioCallback != null) {
			Audio.audioCallback(notificationPeriod * 2, Audio.buffer);
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