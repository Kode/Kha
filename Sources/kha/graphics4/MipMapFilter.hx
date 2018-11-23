package kha.graphics4;

@:enum abstract MipMapFilter(Int) to Int {
	var NoMipFilter = 0;
	var PointMipFilter = 1;
	var LinearMipFilter = 2; // linear texture filter + linear mip filter -> trilinear filter
}
