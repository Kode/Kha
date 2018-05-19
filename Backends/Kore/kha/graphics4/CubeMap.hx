package kha.graphics4;

import haxe.io.Bytes;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics4/Graphics.h>
')

@:headerClassCode("Kore::Graphics4::Texture* texture; Kore::Graphics4::RenderTarget* renderTarget;")
class CubeMap implements Canvas implements Resource {

	private var format: TextureFormat;

	private var graphics4: kha.graphics4.Graphics;

	private function new() {

	}

	public static function createRenderTarget(size: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = null, contextId:Int = 0): CubeMap {
		return create2(size, format == null ? TextureFormat.RGBA32 : format, false, true, depthStencil, contextId);
	}

	public static function create2(size: Int, format: TextureFormat, readable: Bool, renderTarget: Bool, depthStencil: DepthStencilFormat, contextId: Int): CubeMap {
		var cubeMap = new CubeMap();
		cubeMap.format = format;
		if (renderTarget) cubeMap.initRenderTarget(size, getDepthBufferBits(depthStencil), getRenderTargetFormat(format), getStencilBufferBits(depthStencil), contextId);
		return cubeMap;
	}

	@:functionCode('renderTarget = new Kore::Graphics4::RenderTarget(cubeMapSize, depthBufferBits, false, (Kore::Graphics4::RenderTargetFormat)format, stencilBufferBits, contextId); texture = nullptr;')
	private function initRenderTarget(cubeMapSize: Int, depthBufferBits: Int, format: Int, stencilBufferBits: Int, contextId: Int): Void {

	}

	private static function getRenderTargetFormat(format: TextureFormat): Int {
		switch (format) {
		case RGBA32:	// Target32Bit
			return 0;
		case RGBA64:	// Target64BitFloat
			return 1;
		case RGBA128:	// Target128BitFloat
			return 3;
		case DEPTH16:	// Target16BitDepth
			return 4;
		default:
			return 0;
		}
	}

	private static function getDepthBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: -1;
			case DepthOnly: 24;
			case DepthAutoStencilAuto: 24;
			case Depth24Stencil8: 24;
			case Depth32Stencil8: 32;
			case Depth16: 16;
		}
	}

	private static function getStencilBufferBits(depthAndStencil: DepthStencilFormat): Int {
		return switch (depthAndStencil) {
			case NoDepthAndStencil: -1;
			case DepthOnly: -1;
			case DepthAutoStencilAuto: 8;
			case Depth24Stencil8: 8;
			case Depth32Stencil8: 8;
			case Depth16: 0;
		}
	}
	
	private static function getTextureFormat(format: TextureFormat): Int {
		switch (format) {
		case RGBA32:
			return 0;
		case RGBA128:
			return 3;
		case RGBA64:
			return 4;
		case A32:
			return 5;
		default:
			return 1; // Grey 8
		}
	}

	public function unload(): Void {

	}
	
	public function lock(level: Int = 0): Bytes {
		return null;
	}
	
	public function unlock(): Void {

	}

	public var width(get, null): Int;
	public var height(get, null): Int;

	@:functionCode("if (texture != nullptr) return texture->width; else return renderTarget->width;")
	public function get_width(): Int {
		return 0;
	}

	@:functionCode("if (texture != nullptr) return texture->height; else return renderTarget->height;")
	public function get_height(): Int {
		return 0;
	}

	public var g1(get, null): kha.graphics1.Graphics;
	private function get_g1(): kha.graphics1.Graphics {
		return null;
	}
	
	public var g2(get, null): kha.graphics2.Graphics;
	private function get_g2(): kha.graphics2.Graphics {
		return null;
	}
	
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.kore.graphics4.Graphics(this);
		}
		return graphics4;
	}
}
