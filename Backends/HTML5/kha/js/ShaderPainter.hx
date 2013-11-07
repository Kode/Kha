package kha.js;

class ShaderPainter extends kha.ShaderPainter {
	public function new(width: Int, height: Int) {
		super(width, height);
	}
	
	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		var v = cast(video, Video);
		drawImage2(v.texture, 0, 0, v.texture.width, v.texture.height, x, y, width, height);
	}
	
	override public function begin(): Void {
		Sys.gl.colorMask(true, true, true, true);
		super.begin();
	}
	
	override public function end(): Void {
		super.end();
		// Clear alpha for IE11
		Sys.gl.clearColor(1, 1, 1, 1);
		Sys.gl.colorMask(false, false, false, true);
		Sys.gl.clear(Sys.gl.COLOR_BUFFER_BIT);
	}
}
