package kha.audio1;

interface AudioChannel {
	public function play(): Void;
	public function pause(): Void;
	public function stop(): Void;
	public var length(get, null): Float; // Seconds
	private function get_length(): Float;
	public var position(get, null): Float; // Seconds
	private function get_position(): Float;
	public var volume(get, set): Float;
	private function get_volume(): Float;
	private function set_volume(value: Float): Float;
	public var finished(get, null): Bool;
	private function get_finished(): Bool;
}
