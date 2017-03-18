package kha.graphics4;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;

extern class CubeMap implements Canvas implements Resource {

	public static function createRenderTarget(size: Int, format: TextureFormat = TextureFormat.RGBA32, depthStencil: DepthStencilFormat = NoDepthAndStencil): CubeMap;

	public function unload(): Void;
	public function lock(level: Int = 0): Bytes;
	public function unlock(): Void;

	public var size(get, null): Int;
	public var width(get, null): Int;
	public var height(get, null): Int;

	public var g1(get, null): kha.graphics1.Graphics;
	public var g2(get, null): kha.graphics2.Graphics;
	public var g4(get, null): kha.graphics4.Graphics;

	public function set(stage: Int): Void;
	public function setDepth(stage: Int): Void;
}
