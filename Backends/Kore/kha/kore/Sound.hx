package kha.kore;

import sys.io.File;

using StringTools;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio1/Sound.h>
')

@:keep
class Sound extends kha.Sound {
	@:functionCode('
		Kore::Sound* sound = new Kore::Sound(filename.c_str());
		this->_createData(sound->size * 2);
		Kore::s16* left = (Kore::s16*)&sound->left[0];
		Kore::s16* right = (Kore::s16*)&sound->right[0];
		for (int i = 0; i < sound->size; i += 1) {
			uncompressedData->self.data[i * 2 + 0] = (float)(left [i] / 32767.0);
			uncompressedData->self.data[i * 2 + 1] = (float)(right[i] / 32767.0);
		}
		this->length = sound->length;
		this->channels = sound->format.channels;
		delete sound;
	')
	function initWav(filename: String) {

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
	
	function _createData(size: Int): Void {
		uncompressedData = new kha.arrays.Float32Array(size);
	}
}
