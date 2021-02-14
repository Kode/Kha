package kha.korehl;

import haxe.ds.Vector;
import sys.io.File;

using StringTools;

@:keep
class Sound extends kha.Sound {
	function initWav(filename: String) {
		uncompressedData = new kha.arrays.Float32Array();
		var dataSize = new kha.arrays.Uint32Array(1);
		var data = kore_sound_init_wav(StringHelper.convert(filename), dataSize.getData(), length);
		uncompressedData.setData(data, dataSize[0]);
		dataSize.free();
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

	@:hlNative("std", "kore_sound_init_wav") static function kore_sound_init_wav(filename: hl.Bytes, outSize: Pointer, outLength: hl.Ref<Float>): Pointer {
		return null;
	}
}
