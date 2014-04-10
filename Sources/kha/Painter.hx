package kha;

class Painter {
	public function drawImage(img: Image, x: Float, y: Float): Void { }
	public function drawImage2(image: Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float, rotation: Rotation = null): Void { }
	public function setColor(color: Color): Void { }
	public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0): Void { }
	public function fillRect(x: Float, y: Float, width: Float, height: Float): Void { }
	public function setFont(font: Font): Void { }
	
	public function drawChars(text: String, offset: Int, length: Int, x: Float, y: Float): Void {
		drawString(text.substr(offset, length), x, y);
	}
	
	public function drawString(text: String, x: Float, y: Float, scaleX: Float = 1.0, scaleY: Float = 1.0, scaleCenterX: Float = 0.0, scaleCenterY: Float = 0.0): Void { }
	public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0): Void { }
	public function drawVideo(video: Video, x: Float, y: Float, width: Float, height: Float): Void { }
	public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void { }
	public function translate(x: Float, y: Float): Void { }
	
	public function clear(): Void {
		fillRect(0, 0, Game.the.width, Game.the.height);
	}
	
	public function begin(): Void { }
	public function end(): Void { }
	
	public var opacity(get,set): Float;
	
	public function get_opacity(): Float {
		return opacities[opacities.length - 1];
	}
	
	public function set_opacity(value: Float): Float {
		return opacities[opacities.length - 1] = value;
	}
	
	public function pushOpacity(): Void {
		opacities.push(opacity);
	}
	
	public function popOpacity(): Void {
		opacities.pop();
	}
	
	private var opacities: Array<Float>;
	
	public function new() {
		opacities = new Array<Float>();
		opacities.push(1);
	}
}
