package kha.graphics4;

enum MipMapFilter {
	NoMipFilter;
	PointMipFilter;
	LinearMipFilter; //linear texture filter + linear mip filter -> trilinear filter
}
