package kha;

class Painter {
	public function drawImage(img: Image, x: Float, y: Float): Void { }
	public function drawImage2(image: Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float): Void { }
	public function setColor(color: Color): Void { }
	public function drawRect(x: Float, y: Float, width: Float, height: Float): Void { }
	public function fillRect(x: Float, y: Float, width: Float, height: Float): Void { }
	public function setFont(font: Font): Void { }
	
	public function drawChars(text: String, offset: Int, length: Int, x: Float, y: Float): Void {
		drawString(text.substr(offset, length), x, y);
	}
	
	public function drawString(text: String, x: Float, y: Float): Void { }
	public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float): Void { }
	public function drawVideo(video: Video, x: Float, y: Float, width: Float, height: Float): Void { }
	public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float): Void { }
	public function translate(x: Float, y: Float): Void { }
	
	public function clear(): Void {
		fillRect(0, 0, Game.the.width, Game.the.height);
	}
	
	public function begin(): Void { }
	public function end(): Void { }
}
