package kha.graphics4;

import haxe.io.Bytes;

class CubeMap implements Canvas implements Resource {
	public static function createRenderTarget(size: Int, format: TextureFormat, depthStencil: DepthStencilFormat = NoDepthAndStencil,
			contextId: Int = 0): CubeMap {
		return null;
	}

	public function unload(): Void {}

	public function lock(level: Int = 0): Bytes {
		return null;
	}

	public function unlock(): Void {}

	public var width(get, never): Int;
	public var height(get, never): Int;

	function get_width(): Int {
		return 512;
	}

	function get_height(): Int {
		return 512;
	}

	public var g1(get, never): kha.graphics1.Graphics;
	public var g2(get, never): kha.graphics2.Graphics;
	public var g4(get, never): kha.graphics4.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		return null;
	}

	function get_g2(): kha.graphics2.Graphics {
		return null;
	}

	function get_g4(): kha.graphics4.Graphics {
		return null;
	}
}
