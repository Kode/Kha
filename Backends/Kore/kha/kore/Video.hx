package kha.kore;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Video.h>
')

@:headerClassCode('
	Kore::Video* video;
')
class Video extends kha.Video {
	public function new(filename: String) {
		super();
		init(filename);
	}
	
	@:functionCode('
	video = new Kore::Video(filename.c_str());
	')
	private function init(filename: String) {
		
	}
	
	@:functionCode('
	video->play();
	')
	override public function play(loop: Bool = false): Void {
		
	}
	
	@:functionCode('
	video->pause();
	')
	override public function pause(): Void {
		
	}

	@:functionCode('
	video->stop();
	')
	override public function stop(): Void {

	}
	
	@:functionCode('
	return static_cast<int>(video->duration * 1000.0);
	')
	override public function getLength(): Int { // Miliseconds
		return 0;
	}
	
	@functionCode('
	return scast<int>(video->position * 1000.0);
	')
	override public function getCurrentPos(): Int { // Miliseconds
		return 0;
	}
	
	@:functionCode('
	return video->finished;
	')
	override public function isFinished(): Bool {
		return false;
	}

	@:functionCode('
	return video->width();
	')
	override public function width(): Int { return 100; }

	@:functionCode('
	return video->height();
	')
	override public function height(): Int { return 100; }

	@:functionCode('
	delete video;
	video = nullptr;
	')
	override public function unload(): Void {

	}
}
