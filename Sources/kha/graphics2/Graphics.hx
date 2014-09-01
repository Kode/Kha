package kha.graphics2;

import kha.Color;
import kha.Font;
import kha.graphics4.BlendingOperation;
import kha.Image;
import kha.math.Matrix3;

class Graphics {
	public function begin(): Void { }
	public function end(): Void { }
	
	//scale-filtering
	//draw/fillPolygon
	
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
	
	public function get_color(): Color {
		return Color.Black;
	}
	
	public function set_color(color: Color): Color {
		return Color.Black;
	}
	
	public function get_font(): Font {
		return null;
	}
	
	public function set_font(font: Font): Font {
		return null;
	}
	
	public var transformation(get, set): Matrix3; // works on the top of the transformation stack
	
	public function pushTransformation(transformation: Matrix3): Void {
		setTransformation(transformation);
		transformations.push(transformation);
	}
	
	public function popTransformation(): Matrix3 {
		var ret = transformations.pop();
		setTransformation(get_transformation());
		return ret;
	}
	
	public function get_transformation(): Matrix3 {
		return transformations[transformations.length - 1];
	}
	
	public function set_transformation(transformation: Matrix3): Matrix3 {
		setTransformation(transformation);
		return transformations[transformations.length - 1] = transformation;
	}
	
	private inline function translation(tx: Float, ty: Float): Matrix3 {
		return Matrix3.translation(tx, ty) * transformation;
	}
	
	public function translate(tx: Float, ty: Float): Void {
		transformation = translation(tx, ty);
	}
	
	public function pushTranslation(tx: Float, ty: Float): Void {
		pushTransformation(translation(tx, ty));
	}
	
	private inline function rotation(angle: Float, centerx: Float, centery: Float): Matrix3 {
		return Matrix3.translation(centerx, centery) * Matrix3.rotation(angle) * Matrix3.translation(-centerx, -centery) * transformation;
	}
	
	public function rotate(angle: Float, centerx: Float, centery: Float): Void {
		transformation = rotation(angle, centerx, centery);
	}
	
	public function pushRotation(angle: Float, centerx: Float, centery: Float): Void {
		pushTransformation(rotation(angle, centerx, centery));
	}
	
	public var opacity(get, set): Float; // works on the top of the opacity stack
	
	public function pushOpacity(opacity: Float): Void {
		setOpacity(opacity);
		opacities.push(opacity);
	}
	
	public function popOpacity(): Float {
		var ret = opacities.pop();
		setOpacity(get_opacity());
		return ret;
	}
	
	public function get_opacity(): Float {
		return opacities[opacities.length - 1];
	}
	
	public function set_opacity(opacity: Float): Float {
		setOpacity(opacity);
		return opacities[opacities.length - 1] = opacity;
	}
	
	//#if graphics4
	#if !cs
	#if !java
	private var prog: kha.graphics4.Program;
	
	public var program(get, set): kha.graphics4.Program;
	
	private function get_program(): kha.graphics4.Program {
		return prog;
	}
	
	private function set_program(program: kha.graphics4.Program): kha.graphics4.Program {
		setProgram(program);
		return prog = program;
	}
	#end
	#end
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		
	}
	
	private var transformations: Array<Matrix3>;
	private var opacities: Array<Float>;
	
	public function new() {
		transformations = new Array<Matrix3>();
		transformations.push(Matrix3.identity());
		opacities = new Array<Float>();
		opacities.push(1);
		#if !cs
		#if !java
		prog = null;
		#end
		#end
	}
	
	private function setTransformation(transformation: Matrix3): Void {
		
	}
	
	private function setOpacity(opacity: Float): Void {
		
	}
	
	private function setProgram(program: kha.graphics4.Program): Void {
		
	}
}
