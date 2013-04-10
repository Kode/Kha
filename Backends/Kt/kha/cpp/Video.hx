package kha.cpp;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Video.h>
')

@:headerClassCode('Kt::Video* video;')
class Video extends kha.Video {
	public function new(filename: String) {
		super();
		init(filename + ".webm");
	}
	
	@:functionCode('video = new Kt::Video(Kt::Text(filename.c_str()));')
	private function init(filename: String) {
		
	}
	
	@:functionCode('video->play();')
	override public function play(): Void {
		
	}
	
	@:functionCode('video->pause();')
	override public function pause(): Void {
		
	}
	
	@:functionCode('return scast<int>(video->duration * 1000.0);')
	override public function getLength(): Int { // Miliseconds
		return 0;
	}
	
	@functionCode('return scast<int>(video->position * 1000.0);')
	override public function getCurrentPos(): Int { // Miliseconds
		return 0;
	}
	
	@:functionCode('return video->finished;')
	override public function isFinished(): Bool {
		return false;
	}
}
