package android.media;

import android.media.AudioAttributes;

@:native("android.media.AudioAttributes.Builder")
extern class AudioAttributesBuilder {
	public function new(): Void;
	public function build(): AudioAttributes;
	public function setContentType(contentType: Int): AudioAttributesBuilder;
	public function setUsage(usage: Int): AudioAttributesBuilder;
}