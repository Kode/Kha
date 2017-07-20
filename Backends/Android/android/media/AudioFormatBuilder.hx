package android.media;

import android.media.AudioFormat;

@:native("android.media.AudioFormat.Builder")
extern class AudioFormatBuilder {
	public function new(): Void;
	public function build(): AudioFormat;
	public function setChannelMask(channelMask: Int): AudioFormatBuilder;
	public function setEncoding(encoding: Int): AudioFormatBuilder;
	public function setSampleRate(sampleRate: Int): AudioFormatBuilder;
}