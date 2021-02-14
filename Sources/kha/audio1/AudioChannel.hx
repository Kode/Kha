package kha.audio1;

interface AudioChannel {
	function play(): Void;
	function pause(): Void;
	function stop(): Void;
	var length(get, null): Float; // Seconds
	private function get_length(): Float;
	var position(get, set): Float; // Seconds
	private function get_position(): Float;
	private function set_position(value: Float): Float;
	var volume(get, set): Float;
	private function get_volume(): Float;
	private function set_volume(value: Float): Float;
	var finished(get, null): Bool;
	private function get_finished(): Bool;
}
