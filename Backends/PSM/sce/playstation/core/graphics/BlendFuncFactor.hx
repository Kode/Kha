package sce.playstation.core.graphics;

@:native("Sce.PlayStation.Core.Graphics.BlendFuncFactor")
extern enum BlendFuncFactor {
	Zero;
	One;
	SrcColor;
	OneMinusSrcColor;
	SrcAlpha;
	OneMinusSrcAlpha;
	DstColor;
	OneMinusDstColor;
	DstAlpha;
	OneMinusDstAlpha;
	SrcAlphaSaturate;
}
