package kha.graphics2;

import kha.Color;
import kha.FastFloat;
import kha.Font;
import kha.graphics4.BlendingOperation;
import kha.graphics4.PipelineState;
import kha.Image;
import kha.math.FastMatrix3;
import kha.math.Matrix3;

class Graphics {
	public function begin(clear: Bool = true, clearColor: Color = null): Void { }
	public function end(): Void { }
	public function flush(): Void { }
	
	//scale-filtering
	//draw/fillPolygon
	
	public function clear(color: Color = null): Void { }
	public function drawImage(img: Image, x: FastFloat, y: FastFloat): Void {
		drawSubImage(img, x, y, 0, 0, img.width, img.height);
	}
	public function drawSubImage(img: Image, x: FastFloat, y: FastFloat, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat): Void {
		drawScaledSubImage(img, sx, sy, sw, sh, x, y, sw, sh);
	}
	public function drawScaledImage(img: Image, dx: FastFloat, dy: FastFloat, dw: FastFloat, dh: FastFloat): Void {
		drawScaledSubImage(img, 0, 0, img.width, img.height, dx, dy, dw, dh);
	}
	public function drawScaledSubImage(image: Image, sx: FastFloat, sy: FastFloat, sw: FastFloat, sh: FastFloat, dx: FastFloat, dy: FastFloat, dw: FastFloat, dh: FastFloat): Void { }
	public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0): Void { }
	public function fillRect(x: Float, y: Float, width: Float, height: Float): Void { }
	public function drawString(text: String, x: Float, y: Float): Void { }
	public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void { }
	public function drawVideo(video: Video, x: Float, y: Float, width: Float, height: Float): Void { }
	public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void { }
	
	public var imageScaleQuality(get, set): ImageScaleQuality;
	public var mipmapScaleQuality(get, set): ImageScaleQuality;
	
	private function get_imageScaleQuality(): ImageScaleQuality {
		return ImageScaleQuality.Low;
	}
	
	private function set_imageScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		return ImageScaleQuality.High;
	}
	
	private function get_mipmapScaleQuality(): ImageScaleQuality {
		return ImageScaleQuality.Low;
	}

	private function set_mipmapScaleQuality(value: ImageScaleQuality): ImageScaleQuality {
		return ImageScaleQuality.High;
	}
    
	/**
	The color value is used for geometric primitives as well as for images. Remember to set it back to white to draw images unaltered.
	*/
	public var color(get, set): Color;
	
	private function get_color(): Color {
		return Color.Black;
	}
	
	private function set_color(color: Color): Color {
		return Color.Black;
	}
	
	public var font(get, set): Font;
	
	private function get_font(): Font {
		return null;
	}
	
	private function set_font(font: Font): Font {
		return null;
	}
	
	public var fontSize(get, set): Int;
	
	private function get_fontSize(): Int {
		return myFontSize;
	}
	
	private function set_fontSize(value: Int): Int {
		return myFontSize = value;
	}
	
	public var fontGlyphs(get, set): Array<Int>;
	
	private function get_fontGlyphs(): Array<Int> {
		return myFontGlyphs;
	}
	
	private function set_fontGlyphs(value: Array<Int>): Array<Int> {
		return myFontGlyphs = value;
	}
	
	public var transformation(get, set): FastMatrix3; // works on the top of the transformation stack
	
	public function pushTransformation(transformation: FastMatrix3): Void {
		setTransformation(transformation);
		transformations.push(transformation);
	}
	
	public function popTransformation(): FastMatrix3 {
		var ret = transformations.pop();
		setTransformation(get_transformation());
		return ret;
	}
	
	private inline function get_transformation(): FastMatrix3 {
		return transformations[transformations.length - 1];
	}
	
	private inline function set_transformation(transformation: FastMatrix3): FastMatrix3 {
		setTransformation(transformation);
		return transformations[transformations.length - 1] = transformation;
	}
	
	private inline function translation(tx: FastFloat, ty: FastFloat): FastMatrix3 {
		return FastMatrix3.translation(tx, ty).multmat(transformation);
	}
	
	public function translate(tx: FastFloat, ty: FastFloat): Void {
		transformation = translation(tx, ty);
	}
	
	public function pushTranslation(tx: FastFloat, ty: FastFloat): Void {
		pushTransformation(translation(tx, ty));
	}
	
	private inline function rotation(angle: FastFloat, centerx: FastFloat, centery: FastFloat): FastMatrix3 {
		return FastMatrix3.translation(centerx, centery).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-centerx, -centery)).multmat(transformation);
	}
	
	public function rotate(angle: FastFloat, centerx: FastFloat, centery: FastFloat): Void {
		transformation = rotation(angle, centerx, centery);
	}
	
	public function pushRotation(angle: FastFloat, centerx: FastFloat, centery: FastFloat): Void {
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
	
	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		
	}
	
	public function disableScissor(): Void {
		
	}
	
	#if sys_g4
	private var pipe: PipelineState;
	
	public var pipeline(get, set): PipelineState;
	
	private function get_pipeline(): PipelineState {
		return pipe;
	}
	
	private function set_pipeline(pipeline: PipelineState): PipelineState {
		setPipeline(pipeline);
		return pipe = pipeline;
	}
	#end
	
	private var transformations: Array<FastMatrix3>;
	private var opacities: Array<Float>;
	private var myFontSize: Int;
	private var myFontGlyphs: Array<Int>;
	
	public function new() {
		transformations = new Array<FastMatrix3>();
		transformations.push(FastMatrix3.identity());
		opacities = new Array<Float>();
		opacities.push(1);
		myFontSize = 12;
		myFontGlyphs = [];
		for (i in 32...256) {
			myFontGlyphs.push(i);
		}
		#if sys_g4
		pipe = null;
		#end
	}
	
	private function setTransformation(transformation: FastMatrix3): Void {
		
	}
	
	private function setOpacity(opacity: Float): Void {
		
	}
	
	private function setPipeline(pipeline: PipelineState): Void {
		
	}
}
