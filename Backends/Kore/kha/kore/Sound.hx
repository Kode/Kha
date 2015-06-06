package kha.kore;

import haxe.ds.Vector;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio/Sound.h>
#include <Kore/Audio/Mixer.h>
')

@:headerClassCode("Kore::Sound* sound;")
class Sound extends kha.Sound {
	public function new(filename: String) {
		super();
		loadSound(filename + ".wav");
	}
	
	@:functionCode('
		sound = new Kore::Sound(filename.c_str());
		this->_createData(sound->size);
	')
	function loadSound(filename: String) {
		
	}
	
	@:functionCode('channel->sound = sound; Kore::Mixer::play(sound);')
	private function playInternal(channel: kha.kore.SoundChannel): Void {
		
	}
	
	override public function play(): kha.SoundChannel {
		var channel = new kha.kore.SoundChannel();
		playInternal(channel);
		return channel;
	}
	
	@:functionCode("Kore::Mixer::stop(sound); delete sound; sound = nullptr;")
	override public function unload(): Void {

	}
	
	private function _createData(size: Int): Void {
		data = new Vector<Float>(size);
	}
}
