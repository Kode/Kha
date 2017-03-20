package kha.graphics4;

import haxe.io.Bytes;

extern class CubeMap implements Canvas implements Resource {

	public static function createRenderTarget(size: Int, format: TextureFormat = TextureFormat.RGBA32, depthStencil: DepthStencilFormat = NoDepthAndStencil, contextId: Int = 0): CubeMap;

	public function unload(): Void;
	public function lock(level: Int = 0): Bytes;
	public function unlock(): Void;

	public var width(get, null): Int;
	public var height(get, null): Int;

	public var g1(get, null): kha.graphics1.Graphics;
	public var g2(get, null): kha.graphics2.Graphics;
	public var g4(get, null): kha.graphics4.Graphics;
}
