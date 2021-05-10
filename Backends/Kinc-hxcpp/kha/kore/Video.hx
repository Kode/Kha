package kha.kore;

@:headerCode("
//#include <kinc/video.h>
")
// @:headerClassCode("Kore::Video* video;")
class Video extends kha.Video {
	public function new(filename: String) {
		super();
		init(filename);
	}

	// @:functionCode("video = new Kore::Video(filename.c_str());")
	function init(filename: String) {}

	// @:functionCode("video->play();")
	override public function play(loop: Bool = false): Void {}

	// @:functionCode("video->pause();")
	override public function pause(): Void {}

	// @:functionCode("video->stop();")
	override public function stop(): Void {}

	// @:functionCode("return static_cast<int>(video->duration * 1000.0);")
	override public function getLength(): Int { // Miliseconds
		return 0;
	}

	// @:functionCode("return static_cast<int>(video->position * 1000.0);")
	override public function getCurrentPos(): Int { // Miliseconds
		return 0;
	}

	override function get_position(): Int {
		return getCurrentPos();
	}

	// @:functionCode("video->update(value / 1000.0); return value;")
	override function set_position(value: Int): Int {
		return 0;
	}

	// @:functionCode("return video->finished;")
	override public function isFinished(): Bool {
		return false;
	}

	// @:functionCode("return video->width();")
	override public function width(): Int {
		return 100;
	}

	// @:functionCode("return video->height();")
	override public function height(): Int {
		return 100;
	}

	// @:functionCode("delete video; video = nullptr;")
	override public function unload(): Void {}
}
