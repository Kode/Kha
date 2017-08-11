package android.media;

import java.NativeArray;
import android.media.AudioTrackOnPlaybackPositionUpdateListener;
import java.types.Int16;

extern class AudioTrack {
	public function new(streamType:Int, sampleRateInHz:Int, channelConfig:Int, audioFormat:Int, bufferSizeInBytes:Int, mode:Int): Void;
	public function getPositionNotificationPeriod(): Int;
	public function play(): Void;
	public function setPlaybackPositionUpdateListener(listener: AudioTrackOnPlaybackPositionUpdateListener): Void;
	public function setVolume(gain: Float): Int;
	public function stop(): Void;
	public function write(audioData: NativeArray<Int16>, offsetInShorts: Int, sizeInShorts: Int): Int;
	public function setPositionNotificationPeriod(periodInFrames:Int): Int;
	public function setNotificationMarkerPosition(markerInFrames:Int): Int;
	public static function getMinBufferSize(sampleRateInHz:Int, channelConfig:Int, audioFormat:Int): Int;
	
	public static var MODE_STREAM: Int;
}