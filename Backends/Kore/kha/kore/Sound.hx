package kha.kore;

import haxe.ds.Vector;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio1/Sound.h>
')

@:headerClassCode("Kore::Sound* sound;")
@:keep
class Sound extends kha.Sound {
	private var filename: String;
	
	public function new(filename: String) {
		super();
		this.filename = filename;
	}
	
	@:functionCode('
		sound = new Kore::Sound(filename.c_str());
		if (sound->format.channels == 1) {
			if (sound->format.bitsPerSample == 8) {
				this->_createData(sound->size * 2);
				for (int i = 0; i < sound->size; ++i) {
					uncompressedData[i * 2 + 0] = sound->left[i] / 255.0 * 2.0 - 1.0;
					uncompressedData[i * 2 + 1] = sound->left[i] / 255.0 * 2.0 - 1.0;
				}
			}
			else if (sound->format.bitsPerSample == 16) {
				this->_createData(sound->size);
				Kore::s16* left = (Kore::s16*)&sound->left[0];
				for (int i = 0; i < sound->size / 2; ++i) {
					uncompressedData[i * 2 + 0] = left[i] / 32767.0;
					uncompressedData[i * 2 + 1] = left[i] / 32767.0;
				}
			}
			else {
				this->_createData(2);
			}
		}
		else {
			if (sound->format.bitsPerSample == 8) {
				this->_createData(sound->size);
				for (int i = 0; i < sound->size; i += 2) {
					uncompressedData[i] = sound->left[i / 2] / 255.0 * 2.0 - 1.0;
					uncompressedData[i + 1] = sound->right[i / 2 + 1] / 255.0 * 2.0 - 1.0;
				}
			}
			else if (sound->format.bitsPerSample == 16) {
				this->_createData(sound->size / 2);
				Kore::s16* left = (Kore::s16*)&sound->right[0];
				Kore::s16* right = (Kore::s16*)&sound->right[0];
				for (int i = 0; i < sound->size / 2; i += 2) {
					uncompressedData[i] = left[i / 2] / 32767.0;
					uncompressedData[i + 1] = right[i / 2 + 1] / 32767.0;
				}
			}
			else {
				this->_createData(2);
			}
		}
	')
	private function uncompress2(): Void {
		
	}

	override public function uncompress(done: Void->Void): Void {
		uncompress2();
		compressedData = null;
		done();
	}
	
	@:functionCode("delete sound; sound = nullptr;")
	private function unload2(): Void {
		
	}
		
	override public function unload(): Void {
		super.unload();
		unload2();
	}
	
	private function _createData(size: Int): Void {
		uncompressedData = new Vector<Float>(size);
	}
}
