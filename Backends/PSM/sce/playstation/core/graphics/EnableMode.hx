package sce.playstation.core.graphics;

@:native("Sce.PlayStation.Core.Graphics.EnableMode")
extern enum EnableMode {
	None;
	ScissorTest;
	CullFace;
	Blend;
	DepthTest;
	PolygonOffsetFill;
	StencilTest;
	Dither;
	All;
}
