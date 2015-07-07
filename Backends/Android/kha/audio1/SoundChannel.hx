package kha.audio1;

class SoundChannel {
	public function play(): Void {
		
	}

	public function pause(): Void {
		
	}

	public function stop(): Void {
		
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
