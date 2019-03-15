package kha.graphics4;

@:enum abstract TextureAddressing(Int) to Int {
	var Repeat = 0;
	var Mirror = 1;
	var Clamp = 2;
}
