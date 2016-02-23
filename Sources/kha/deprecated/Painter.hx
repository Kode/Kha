package kha.deprecated;

import kha.Canvas;
import kha.Image;
import kha.math.FastMatrix3;

class Painter {
	private var backbuffer: Image;
	private var opacities: Array<Float>;
	
	public function new(width: Int, height: Int) {
		this.backbuffer = Image.createRenderTarget(width, height);
		opacities = new Array<Float>();
		opacities.push(1);
	}
	
	public function drawImage(img: Image, x: Float, y: Float): Void {
		backbuffer.g2.drawImage(img, x, y);
	}
	
	public function drawImage2(image: Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, angle: Float = 0, ox: Float = 0, oy: Float = 0): Void {
		if (angle != 0) {
			backbuffer.g2.pushTransformation(FastMatrix3.translation(ox, oy).multmat(FastMatrix3.rotation(angle)).multmat(FastMatrix3.translation(-ox, -oy)));
			backbuffer.g2.drawScaledSubImage(image, sx, sy, sw, sh, dx, dy, dw, dh);
			backbuffer.g2.popTransformation();
		}
		else {
			backbuffer.g2.drawScaledSubImage(image, sx, sy, sw, sh, dx, dy, dw, dh);
		}
	}
	
	public function setColor(color: Color): Void {
		backbuffer.g2.color = color;
	}
	
	public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0): Void {
		backbuffer.g2.drawRect(x, y, width, height, strength);
	}
	
	public function fillRect(x: Float, y: Float, width: Float, height: Float): Void {
		backbuffer.g2.fillRect(x, y, width, height);
	}
	
	public function setFont(font: Font): Void {
		backbuffer.g2.font = font;
	}
	
	public function drawChars(text: String, offset: Int, length: Int, x: Float, y: Float): Void {
		drawString(text.substr(offset, length), x, y);
	}
	
	public function drawString(text: String, x: Float, y: Float, scaleX: Float = 1.0, scaleY: Float = 1.0, scaleCenterX: Float = 0.0, scaleCenterY: Float = 0.0): Void {
		if (scaleX != 1 || scaleY != 1) {
			backbuffer.g2.pushTransformation(FastMatrix3.translation(scaleCenterX, scaleCenterY).multmat(FastMatrix3.scale(scaleX, scaleY)).multmat(FastMatrix3.translation(-scaleCenterX, -scaleCenterY)));
			backbuffer.g2.drawString(text, x, y);
			backbuffer.g2.popTransformation();
		}
		else {
			backbuffer.g2.drawString(text, x, y);
		}
	}
	
	public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void {
		backbuffer.g2.drawLine(x1, y1, x2, y2, strength);
	}
	
	public function drawVideo(video: Video, x: Float, y: Float, width: Float, height: Float): Void {
		backbuffer.g2.drawVideo(video, x, y, width, height);
	}
	
	public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void {
		backbuffer.g2.fillTriangle(x1, y1, x2, y2, x3, y3);
	}
	
	public function translate(x: Float, y: Float): Void { }
	
	public function clear(): Void {
		fillRect(0, 0, System.pixelWidth, System.pixelHeight);
	}
	
	public function begin(): Void {
		backbuffer.g2.begin();
	}
	
	public function end(): Void {
		backbuffer.g2.end();
	}
	
	public var opacity(get,set): Float;
	
	public function get_opacity(): Float {
		return opacities[opacities.length - 1];
	}
	
	public function set_opacity(value: Float): Float {
		backbuffer.g2.opacity = value;
		return opacities[opacities.length - 1] = value;
	}
	
	public function pushOpacity(): Void {
		opacities.push(opacity);
	}
	
	public function popOpacity(): Void {
		opacities.pop();
	}
	
	public function render(canvas: Canvas): Void {
		Scaler.scale(backbuffer, canvas, System.screenRotation);
	}
}
