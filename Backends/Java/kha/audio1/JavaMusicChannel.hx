package kha.audio1;

class JavaMusicChannel implements kha.audio1.AudioChannel {
	var music: kha.java.Music;
	var loop: Bool;

	public function new(music: kha.java.Music, loop: Bool) {
		this.music = music;
		play();
	}

	public function play(): Void {
		music.play(loop);
	}

	public function pause(): Void {
		music.stop();
	}

	public function stop(): Void {
		music.stop();
	}

	public var length(get, never): Int;

	function get_length(): Int {
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
