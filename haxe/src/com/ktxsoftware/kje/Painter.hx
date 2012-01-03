package com.ktxsoftware.kje;

class Painter {
	public function drawImage(img : Image, x : Float, y : Float) { }
	public function drawImage2(image : Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) { }
	public function setColor(r : Int, g : Int, b : Int) { }
	public function drawRect(x : Float, y : Float, width : Float, height : Float) { }
	public function fillRect(x : Float, y : Float, width : Float, height : Float) { }
	public function setFont(font : Font) { }
	public function drawChars(text : String, offset : Int, length : Int, x : Float, y : Float) { }
	public function drawString(text : String, x : Float, y : Float) { }
	public function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) { }
	public function fillTriangle(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) { }
	public function translate(x : Float, y : Float) { }
	public function clear() {
		fillRect(0, 0, Game.getInstance().getWidth(), Game.getInstance().getHeight());
	}
	public function begin() { }
	public function end() { }
}