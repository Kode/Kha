package kha.audio1;

extern class SoundChannel {
	function play(): Void;
	function pause(): Void;
	function stop(): Void;
	var length(get, null): Int; // Miliseconds
	function get_length(): Int;
	var position(get, null): Int; // Miliseconds
	function get_position(): Int;
	var volume(get, set): Float;
	function get_volume(): Float;
	function set_volume(value: Float): Float;
	var finished(get, null): Bool;
	function get_finished(): Bool;
}
