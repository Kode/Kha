package kha.graphics2;

import kha.Color;
import kha.FastFloat;
import kha.graphics4.PipelineState;
import kha.Image;
import kha.math.FastMatrix3;
import kha.graphics2.Primitive;

class Graphics {
	public var style:Style;

	public function begin(clear: Bool = true, clearColor: Color = null): Void { }
	public function end(): Void { }
	public function flush(): Void { }
	
	//scale-filtering
	//draw/fillPolygon
	
	public function clear(color: Color = null): Void { }
	public function image(img: Image, x: FastFloat, y: FastFloat, ?style: Style): Void {
		subImage(img, x, y, 0, 0, img.width, img.height, style);
	}
	public function subImage(img: Image, x: FastFloat, y: FastFloat, left: FastFloat, top: FastFloat, width: FastFloat, height: FastFloat, ?style: Style): Void {
		scaledSubImage(img, x, y, left, top, width, height, width, height, style);
	}
	public function scaledImage(img: Image, x: FastFloat, y: FastFloat, finalWidth: FastFloat, finalHeight: FastFloat, ?style: Style): Void {
		scaledSubImage(img, x, y, 0, 0, img.width, img.height, finalWidth, finalHeight, style);
	}
	public function scaledSubImage(image: Image, x: FastFloat, y: FastFloat, left: FastFloat, top: FastFloat, width: FastFloat, height: FastFloat, finalWidth: FastFloat, finalHeight: FastFloat, ?style: Style): Void { }

	// Clockwise or counter-clockwise around the defined shape
	public function quad(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, x4: Float, y4: Float, ?style:Style): Void { }
	public function rect(x: Float, y: Float, width: Float, height: Float, ?style:Style): Void { }
	public function line(x1: Float, y1: Float, x2: Float, y2: Float, ?style:Style): Void { }
	public function triangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, ?style:Style): Void { }
	public function ellipse(x: Float, y: Float, width: Float, height: Float, ?style:Style): Void { }
	
	public function beginShape(primitive:Primitive, ?style:Style): Void { }
	public function vertex(x:Float, y:Float): Void { }
	public function endShape(close:Bool): Void { }

	public function text(text: String, x: Float, y: Float, ?style: Style): Void { }
	public function drawVideo(video: Video, x: Float, y: Float, width: Float, height: Float, ?style: Style): Void { }
	
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

	inline public function getTransform() {
		return transform;
	}

	public function setTransform(transform: FastMatrix3): Void {
		this.transform = transform;
	}

	public function resetTransform() {
		transformStack.splice(0, transformStack.length);
		transform = FastMatrix3.identity();
	}
	
	public function translate(x: FastFloat, y: FastFloat): Void {
		transform = transform.multmat(FastMatrix3.translation(x, y));
	}

	public function scale(x: FastFloat, y: FastFloat): Void {
		transform = transform.multmat(FastMatrix3.scale(x, y));
	}
	
	public function rotate(angle: FastFloat): Void {
		transform = transform.multmat(FastMatrix3.rotation(angle));
	}

	public function push() {
		transformStack.push(transform.mult(1));
	}

	public function pop() {
		transform = transformStack.pop();
		return transform;
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
	
	private var transformStack: Array<FastMatrix3>;
	private var transform: FastMatrix3;
	
	public function new() {
		transformStack = new Array<FastMatrix3>();
		transform = FastMatrix3.identity();

		#if sys_g4
		pipe = null;
		#end

		style = new Style();
	}
	
	private function setPipeline(pipeline: PipelineState): Void {
		
	}
}
