package kha.audio1;

class JavaSoundChannel implements kha.audio1.AudioChannel {
	var sound: kha.java.Sound;

	public function new(sound: kha.java.Sound) {
		this.sound = sound;
		play();
	}

	public function play(): Void {
		sound.play();
	}

	public function pause(): Void {
		sound.stop();
	}

	public function stop(): Void {
		sound.stop();
	}

	public var length(get, never): Float;

	function get_length(): Float {
		return 0;
	}

	public var position(get, set): Float;

	function get_position(): Float {
		return 0.0;
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
		return false;
	}
}
