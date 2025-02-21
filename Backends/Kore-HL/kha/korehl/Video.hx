package kha.korehl;

class Video extends kha.Video {
	public var _video: Pointer;

	public function new(filename: String) {
		super();
		init(filename);
	}

	function init(filename: String) {
		_video = kinc_video_create(StringHelper.convert(filename));
	}

	override public function play(loop: Bool = false): Void {
		kinc_video_play(_video);
	}

	override public function pause(): Void {
		kinc_video_pause(_video);
	}

	override public function stop(): Void {
		kinc_video_stop(_video);
	}

	override public function getLength(): Int { // Miliseconds
		return kinc_video_get_duration(_video);
	}

	override public function getCurrentPos(): Int { // Miliseconds
		return kinc_video_get_position(_video);
	}

	override function get_position(): Int {
		return getCurrentPos();
	}

	override function set_position(value: Int): Int {
		kinc_video_set_position(_video, value);
		return value;
	}

	override public function isFinished(): Bool {
		return kinc_video_is_finished(_video);
	}

	override public function width(): Int {
		return kinc_video_width(_video);
	}

	override public function height(): Int {
		return kinc_video_height(_video);
	}

	override public function unload(): Void {
		kinc_video_unload(_video);
	}

	@:hlNative("std", "kinc_video_create") static function kinc_video_create(filename: hl.Bytes): Pointer {
		return null;
	}

	@:hlNative("std", "kinc_video_play") static function kinc_video_play(video: Pointer): Void {}

	@:hlNative("std", "kinc_video_pause") static function kinc_video_pause(video: Pointer): Void {}

	@:hlNative("std", "kinc_video_stop") static function kinc_video_stop(video: Pointer): Void {}

	@:hlNative("std", "kinc_video_get_duration") static function kinc_video_get_duration(video: Pointer): Int {
		return 0;
	}

	@:hlNative("std", "kinc_video_get_position") static function kinc_video_get_position(video: Pointer): Int {
		return 0;
	}

	@:hlNative("std", "kinc_video_set_position") static function kinc_video_set_position(video: Pointer, value: Int): Int {
		return 0;
	}

	@:hlNative("std", "kinc_video_is_finished") static function kinc_video_is_finished(video: Pointer): Bool {
		return false;
	}

	@:hlNative("std", "kinc_video_width") static function kinc_video_width(video: Pointer): Int {
		return 0;
	}

	@:hlNative("std", "kinc_video_height") static function kinc_video_height(video: Pointer): Int {
		return 0;
	}

	@:hlNative("std", "kinc_video_unload") static function kinc_video_unload(video: Pointer): Void {}
}
