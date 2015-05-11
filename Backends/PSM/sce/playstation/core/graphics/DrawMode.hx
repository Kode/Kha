package sce.playstation.core.graphics;

@:native("Sce.PlayStation.Core.Graphics.DrawMode")
extern enum DrawMode {
	Points;
	Lines;
	LineStrip;
	Triangles;
	TriangleStrip;
	TriangleFan;
}
