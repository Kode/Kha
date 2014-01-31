package kha.cpp;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Audio/SoundStream.h>
#include <Kore/Audio/Mixer.h>
')

@:headerClassCode("Kore::SoundStream* stream;")
class Music extends kha.Music {
	public function new(filename: String) {
		super();
		loadMusic(filename + ".ogg");
	}
	
	@:functionCode("stream = new Kore::SoundStream(filename.c_str(), true);")
	function loadMusic(filename: String) {
		
	}
	
	@:functionCode('
		stream->reset();
		stream->setLooping(loop);
		Kore::Mixer::play(stream);
	')
	override public function play(loop: Bool = false): Void {
		
	}
	
	@:functionCode("Kore::Mixer::stop(stream);")
	override public function stop(): Void {
		
	}
	
	@:functionCode('return stream->position() * 1000;')
	override public function getCurrentPos(): Int {
		return 0;
	}
	
	@:functionCode('return stream->length() * 1000;')
	override public function getLength(): Int {
		return 0;
	}
}
