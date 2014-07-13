package kha.graphics2;

import kha.Color;
import kha.Image;
import kha.math.Matrix3;

class Graphics {
	public function begin(): Void { }
	public function end(): Void { }
	
	public function clear(): Void { }
	public function drawImage(img: Image, x: Float, y: Float): Void {
		drawSubImage(img, x, y, 0, 0, img.width, img.height);
	}
	public function drawSubImage(img: Image, x: Float, y: Float, sx: Float, sy: Float, sw: Float, sh: Float): Void {
		drawScaledSubImage(img, sx, sy, sw, sh, x, y, img.width, img.height);
	}
	public function drawScaledImage(img: Image, dx: Float, dy: Float, dw: Float, dh: Float): Void {
		drawScaledSubImage(img, 0, 0, img.width, img.height, dx, dy, dw, dh);
	}
	public function drawScaledSubImage(image: Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float): Void { }
	public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0): Void { }
	public function fillRect(x: Float, y: Float, width: Float, height: Float): Void { }
	public function drawString(text: String, x: Float, y: Float): Void { }
	public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void { }
	public function drawVideo(video: Video, x: Float, y: Float, width: Float, height: Float): Void { }
	public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void { }
	
	public var color(get, set): Color;
	public var font(get, set): Font;
	
	public var transformation(get, set): Matrix3; // works on the top of the transformation stack
	
	public function pushTransformation(transformation: Matrix3): Void {
		transformations.push(transformation);
	}
	
	public function popTransformation(): Matrix3 {
		return transformations.pop();
	}
	
	public function get_transformation(): Matrix3 {
		return transformations[transformations.length - 1];
	}
	
	public function set_transformation(transformation: Matrix3): Matrix3 {
		return transformations[transformations.length - 1] = transformation;
	}
	
	public var opacity(get, set): Float; // works on the top of the opacity stack
	
	public function pushOpacity(opacity: Float): Void {
		opacities.push(opacity);
	}
	
	public function popOpacity(): Float {
		return opacities.pop();
	}
	
	public function get_opacity(): Float {
		return opacities[opacities.length - 1];
	}
	
	public function set_opacity(opacity: Float): Float {
		return opacities[opacities.length - 1] = opacity;
	}
	
	#if graphics4
	public var vertexShader(get, set): kha.graphics4.VertexShader;
	public var fragmentShader(get, set): kha.graphics4.FragmentShader;
	#end
	
	private var transformations: Array<Matrix3>;
	private var opacities: Array<Float>;
	
	public function new() {
		transformations = new Array<Matrix3>();
		transformations.push(Matrix3.identity());
		opacities = new Array<Float>();
		opacities.push(1);
	}
}
