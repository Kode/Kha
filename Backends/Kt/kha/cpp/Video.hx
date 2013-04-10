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
	public override function play(): Void {
		
	}
	
	@:functionCode('video->pause();')
	public override function pause(): Void {
		
	}
}
