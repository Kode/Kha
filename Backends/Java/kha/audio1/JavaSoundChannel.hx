package kha.audio1;

class JavaSoundChannel implements kha.audio1.AudioChannel {
	private var sound: kha.java.Sound;
	
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

	public var length(get, null): Float;
	
	private function get_length(): Float {
		return 0;
	}

	public var position(get, null): Float;
	
	private function get_position(): Float {
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
