package kha;

@:structInit
class FramebufferOptions {
	@:optional public var frequency: Int = 60;
	@:optional public var verticalSync: Bool = true;
	@:optional public var colorBufferBits: Int = 32;
	@:optional public var depthBufferBits: Int = 16;
	@:optional public var stencilBufferBits: Int = 8;
	@:optional public var samplesPerPixel: Int = 1;

	public function new(?frequency: Int = 60, ?verticalSync: Bool = true, ?colorBufferBits: Int = 32, ?depthBufferBits: Int = 16, ?stencilBufferBits: Int = 8, ?samplesPerPixel: Int = 1) {
		this.frequency = frequency;
		this.verticalSync = verticalSync;
		this.colorBufferBits = colorBufferBits;
		this.depthBufferBits = depthBufferBits;
		this.stencilBufferBits = stencilBufferBits;
		this.samplesPerPixel = samplesPerPixel;
	}
}
