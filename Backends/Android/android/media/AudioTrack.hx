package android.media;

import java.lang.Float;
import java.NativeArray;
import android.media.AudioTrackOnPlaybackPositionUpdateListener;

extern class AudioTrack {
	public function flush(): Void;
	public function getPositionNotificationPeriod(): Int;
	public function pause(): Void;
	public function play(): Void;
	public function setPlaybackPositionUpdateListener(listener: AudioTrackOnPlaybackPositionUpdateListener): Void;
	public function setVolume(gain: Float): Int;
	public function stop(): Void;
	public function write(audioData: NativeArray<Float>, offsetInFloats: Int, sizeInFloats: Int, writeMode: Int): Int;
	public function getBufferSizeInFrames(): Int;
	public static function getNativeOutputSampleRate(streamType: Int): Int;
	public static function getMinBufferSize(sampleRateInHz:Int, channelConfig:Int, audioFormat:Int): Int;
	
	public static var MODE_STREAM: Int;
	public static var WRITE_BLOCKING: Int;
}