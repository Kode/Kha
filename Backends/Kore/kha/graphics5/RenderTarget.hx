package kha.graphics5;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics5/Graphics.h>
')

@:headerClassCode("Kore::Graphics5::RenderTarget* renderTarget;")
class RenderTarget {
	
	public function new(width: Int, height: Int, depthBufferBits: Int, antialiasing: Bool, format: TextureFormat, stencilBufferBits: Int, contextId: Int) {
		init(width, height, depthBufferBits, antialiasing, getRenderTargetFormat(format), stencilBufferBits, contextId);
	}

	@:functionCode('renderTarget = new Kore::Graphics5::RenderTarget(width, height, depthBufferBits, antialiasing, (Kore::Graphics5::RenderTargetFormat)format, stencilBufferBits, contextId);')
	private function init(width: Int, height: Int, depthBufferBits: Int, antialiasing: Bool, format: Int, stencilBufferBits: Int, contextId: Int): Void {

	}

	private static function getRenderTargetFormat(format: TextureFormat): Int {
		switch (format) {
		case RGBA32:	// Target32Bit
			return 0;
		case RGBA64:	// Target64BitFloat
			return 1;
		case A32:		// Target32BitRedFloat
			return 2;
		case RGBA128:	// Target128BitFloat
			return 3;
		case DEPTH16:	// Target16BitDepth
			return 4;
		case L8:
			return 5;	// Target8BitRed
		case A16:
			return 6;	// Target16BitRedFloat
		default:
			return 0;
		}
	}
}
