package android.media;

import android.media.AudioTrack;
import android.media.AudioAttributes;
import android.media.AudioFormat;

@:native("android.media.AudioTrack.Builder")
extern class AudioTrackBuilder {
	public function new(): Void;
	public function build(): AudioTrack;
	public function setAudioAttributes(attributes: AudioAttributes): AudioTrackBuilder;
	public function setAudioFormat(format: AudioFormat): AudioTrackBuilder;
	public function setBufferSizeInBytes(bufferSizeInBytes: Int): AudioTrackBuilder;
	public function setSessionId(sessionId: Int): AudioTrackBuilder;
	public function setTransferMode(mode: Int): AudioTrackBuilder;
}