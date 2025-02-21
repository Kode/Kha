package kha.kore;

@:headerCode("
#include <kinc/video.h>
")
@:headerClassCode("kinc_video_t video;")
class Video extends kha.Video {
	public function new(filename: String) {
		super();
		init(filename);
	}

	@:functionCode("kinc_video_init(&video, filename.c_str());")
	function init(filename: String) {}

	@:functionCode("kinc_video_play(&video, loop);")
	override public function play(loop: Bool = false): Void {}

	@:functionCode("kinc_video_pause(&video);")
	override public function pause(): Void {}

	@:functionCode("kinc_video_stop(&video);")
	override public function stop(): Void {}

	override function update(time: Float) {
		untyped __cpp__('kinc_video_update(&video, time)');
	}

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

	override public function isFinished(): Bool {
		return untyped __cpp__("kinc_video_finished(&video)");
	}

	override public function width(): Int {
		return untyped __cpp__("kinc_video_width(&video)");
	}

	override public function height(): Int {
		return untyped __cpp__("kinc_video_height(&video)");
	}

	@:functionCode("kinc_video_destroy(&video);")
	override public function unload(): Void {}
}
