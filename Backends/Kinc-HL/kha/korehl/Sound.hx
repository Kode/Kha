package kha.korehl;

import haxe.ds.Vector;
import sys.io.File;

using StringTools;

@:keep
class Sound extends kha.Sound {
	function initWav(filename: String) {
		var dataSize = new kha.arrays.Uint32Array(1);
		final sampleRateRef: hl.Ref<Int> = sampleRate;
		final lengthRef: hl.Ref<Float> = length;
		var data = kinc_sound_init_wav(StringHelper.convert(filename), dataSize.getData(), sampleRateRef, lengthRef);
		sampleRate = sampleRateRef.get();
		length = lengthRef.get();
		uncompressedData = cast new kha.arrays.ByteArray(data, 0, dataSize[0] * 4);
		(cast dataSize : kha.arrays.ByteArray).free();
	}

	function initOgg(filename: String) {
		compressedData = File.getBytes(filename);
	}

	public function new(filename: String) {
		super();
		if (filename.endsWith(".wav")) {
			initWav(filename);
		}
		else if (filename.endsWith(".ogg")) {
			initOgg(filename);
		}
		else {
			trace("Unknown sound format: " + filename);
		}
	}

	@:hlNative("std", "kinc_sound_init_wav") static function kinc_sound_init_wav(filename: hl.Bytes, outSize: Pointer, outSampleRate: hl.Ref<Int>,
			outLength: hl.Ref<Float>): Pointer {
		return null;
	}
}
