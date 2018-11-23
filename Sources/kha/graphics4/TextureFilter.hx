package kha.graphics4;

@:enum abstract TextureFilter(Int) to Int {
	var PointFilter = 0;
	var LinearFilter = 1;
	var AnisotropicFilter = 2;
}
