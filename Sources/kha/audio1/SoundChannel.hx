package kha.audio1;

extern class SoundChannel {
	public function play(): Void;
	public function pause(): Void;
	public function stop(): Void;
	public var length(get, null): Int; // Miliseconds
	private function get_length(): Int;
	public var position(get, null): Int; // Miliseconds
	private function get_position(): Int;
	public var volume(get, set): Float;
	private function get_volume(): Float;
	private function set_volume(value: Float): Float;
	public var finished(get, null): Bool;
	private function get_finished(): Bool;
}
