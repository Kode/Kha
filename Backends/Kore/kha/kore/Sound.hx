package kha.kore;

import haxe.ds.Vector;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio/Sound.h>
#include <Kore/Audio/Mixer.h>
')

@:headerClassCode("Kore::Sound* sound;")
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
					uncompressedData[i * 2 + 0] = sound->data[i] / 255.0 * 2.0 - 1.0;
					uncompressedData[i * 2 + 1] = sound->data[i] / 255.0 * 2.0 - 1.0;
				}
			}
			else if (sound->format.bitsPerSample == 16) {
				this->_createData(sound->size);
				Kore::s16* sdata = (Kore::s16*)&sound->data[0];
				for (int i = 0; i < sound->size / 2; ++i) {
					uncompressedData[i * 2 + 0] = sdata[i] / 32767.0;
					uncompressedData[i * 2 + 1] = sdata[i] / 32767.0;
				}
			}
			else {
				this->_createData(2);
			}
		}
		else {
			if (sound->format.bitsPerSample == 8) {
				this->_createData(sound->size);
				for (int i = 0; i < sound->size; ++i) {
					uncompressedData[i] = sound->data[i] / 255.0 * 2.0 - 1.0;
				}
			}
			else if (sound->format.bitsPerSample == 16) {
				this->_createData(sound->size / 2);
				Kore::s16* sdata = (Kore::s16*)&sound->data[0];
				for (int i = 0; i < sound->size / 2; ++i) {
					uncompressedData[i] = sdata[i] / 32767.0;
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
	
	//@:functionCode('channel->sound = sound; Kore::Mixer::play(sound);')
	//private function playInternal(channel: kha.kore.SoundChannel): Void {
	//	
	//}
	
	//override public function play(): kha.SoundChannel {
	//	var channel = new kha.kore.SoundChannel();
	//	playInternal(channel);
	//	return channel;
	//}
	
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
