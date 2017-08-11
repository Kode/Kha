package kha.audio2;

//import java.NativeArray;
//import android.media.AudioTrack;
//import android.media.AudioManager;
//import android.media.AudioFormat;
//import android.media.AudioTrackOnPlaybackPositionUpdateListener;
//import java.types.Int16;

class Audio {
	//private static var audioTrack: AudioTrack;
	//private static var listener: UpdateListener;
	//private static var buffersizeInBytes: Int;
	//public static var buffer: Buffer;
	//
	public static var audioCallback: Int->Buffer->Void;
	//
	//public static function initAudioTrack(): Void {
		//var sampleRate = 44100;
		//buffersizeInBytes = AudioTrack.getMinBufferSize(sampleRate, AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT) * 2;
	//
		//audioTrack = new AudioTrack(AudioManager.STREAM_MUSIC, sampleRate, AudioFormat.CHANNEL_OUT_STEREO,
									//AudioFormat.ENCODING_PCM_16BIT, buffersizeInBytes, AudioTrack.MODE_STREAM);
		//
	//}
	
	@:noCompletion
	public static function _init(): Bool {
		//try {
			//initAudioTrack();
			//var buffersize = Math.ceil(buffersizeInBytes / 4); // stereo 16 bit samples
			//buffer = new Buffer(buffersize, 2, 44100);
			//var notificationPeriod = Math.ceil(buffersize / 2);
			//audioTrack.setPositionNotificationPeriod(notificationPeriod);
			//listener = new UpdateListener(notificationPeriod);
			//audioTrack.setPlaybackPositionUpdateListener(listener);
			//// prime the AudioTrack buffer to ensure playback
			//var zeros = new NativeArray<Int16>(buffersize * 2);
			//for (i in 0...buffersize) {
				//zeros[2 * i + 0] = 0;
				//zeros[2 * i + 1] = 0;
			//}
			//audioTrack.write(zeros, 0, buffersize * 2);
			//
			//audioTrack.play();
			//return true;
		//}
		//catch (e: Dynamic) {
			//return false;
		//}
		return false;
	}
	
	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}

	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return null;
	}
}

//private class UpdateListener implements AudioTrackOnPlaybackPositionUpdateListener {
	//private var chunk:NativeArray<Int16>;
	//private var notificationPeriod:Int;
	//
	//public function new(notificationPeriod:Int): Void {
		//this.notificationPeriod = notificationPeriod;
		//chunk = new NativeArray<Int16>(notificationPeriod * 2);
	//}
	//
	//public function onMarkerReached(track: AudioTrack): Void {
		//return null;
	//}
	//
	//public function onPeriodicNotification(track: AudioTrack): Void {
		//if (Audio.audioCallback != null) {
			//Audio.audioCallback(notificationPeriod * 2, Audio.buffer);
			//for (i in 0...notificationPeriod * 2) {
				//// convert PCM_FLOAT from Audio1 back to PCM_16
				//chunk[i] = Math.floor(Audio.buffer.data.get(Audio.buffer.readLocation) * 32768);
				//Audio.buffer.readLocation += 1;
				//if (Audio.buffer.readLocation >= Audio.buffer.size) {
					//Audio.buffer.readLocation = 0;
				//}
			//}
		//}
		//else {
			//for (i in 0...notificationPeriod * 2) {
				//chunk[i] = 0;
			//}
		//}
		//track.write(chunk, 0, notificationPeriod * 2);
	//}
//}