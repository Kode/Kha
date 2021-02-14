package kha.audio1;

class NodeAudioChannel implements AudioChannel {
	public function new() {}

	public function play(): Void {}

	public function pause(): Void {}

	public function stop(): Void {}

	public var length(get, never): Float;

	function get_length(): Float {
		return 0;
	}

	public var position(get, set): Float;

	function get_position(): Float {
		return 0;
	}

	function set_position(value: Float): Float {
		return value;
	}

	public var volume(get, set): Float;

	function get_volume(): Float {
		return 1;
	}

	function set_volume(value: Float): Float {
		return 1;
	}

	public var finished(get, never): Bool;

	function get_finished(): Bool {
		return true;
	}
}
