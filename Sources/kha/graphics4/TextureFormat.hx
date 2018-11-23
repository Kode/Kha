package kha.graphics4;

@:enum abstract TextureFormat(Int) to Int {
	var RGBA32 = 0;
	var L8 = 1;
	var RGBA128 = 2; // Floats
	var DEPTH16 = 3;
	var RGBA64 = 4; // Half floats
	var A32 = 5; // Float
	var A16 = 6; // Half float
}
