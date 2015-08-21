package kha.audio1;

class JavaMusicChannel implements kha.audio1.MusicChannel {
	private var music: kha.java.Music;
	private var loop: Bool;
	
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
	public var length(get, null): Int;
	
	private function get_length(): Int {
		return 0;
	}
	
	public var position(get, null): Int;
	
	private function get_position(): Int {
		return 0;
	}
	
	public var volume(get, set): Float;
	
	private function get_volume(): Float {
		return 1;
	}

	private function set_volume(value: Float): Float {
		return 1;
	}

	public var finished(get, null): Bool;
	
	private function get_finished(): Bool {
		return false;
	}
}