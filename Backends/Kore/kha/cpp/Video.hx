package kha.cpp;

@:headerCode('
#include <Kore/pch.h>
#ifdef KOREVIDEO
#include <Kore/Video.h>
#endif
')

@:headerClassCode('
#ifdef KOREVIDEO
	Kore::Video* video;
#endif
')
class Video extends kha.Video {
	public function new(filename: String) {
		super();
		init(filename + ".theora");
	}
	
	@:functionCode('
	#ifdef KOREVIDEO
	video = new Kore::Video(filename.c_str());
	#endif
	')
	private function init(filename: String) {
		
	}
	
	@:functionCode('
	#ifdef KOREVIDEO
	video->play();
	#endif
	')
	override public function play(loop: Bool = false): Void {
		
	}
	
	@:functionCode('
	#ifdef KOREVIDEO
	video->pause();
	#endif
	')
	override public function pause(): Void {
		
	}
	
	@:functionCode('
	#ifdef KOREVIDEO
	return static_cast<int>(video->duration * 1000.0);
	#endif
	')
	override public function getLength(): Int { // Miliseconds
		return 0;
	}
	
	@functionCode('
	#ifdef KOREVIDEO
	return scast<int>(video->position * 1000.0);
	#endif
	')
	override public function getCurrentPos(): Int { // Miliseconds
		return 0;
	}
	
	@:functionCode('
	#ifdef KOREVIDEO
	return video->finished;
	#endif
	')
	override public function isFinished(): Bool {
		return false;
	}

	@:functionCode('
	#ifdef KOREVIDEO
	return video->width();
	#endif
	')
	override public function width() : Int { return 100; }

	@:functionCode('
	#ifdef KOREVIDEO
	return video->height();
	#endif
	')
	override public function height() : Int { return 100; }
}
