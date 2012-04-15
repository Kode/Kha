package com.ktxsoftware.kha.backends.js;

class Painter extends com.ktxsoftware.kha.Painter {
	var canvas : Dynamic;
	var tx : Float;
	var ty : Float;
	var width : Int;
	var height : Int;
	static var instance : Painter;
	
	public function new(canvas : Dynamic, width : Int, height : Int) {
		this.canvas = canvas;
		this.width = width;
		this.height = height;
		tx = 0;
		ty = 0;
		instance = this;
	}
	
	public static function stringWidth(font : com.ktxsoftware.kha.Font, text : String) {
		if (instance == null) return 5 * text.length;
		else {
			instance.setFont(font);
			return instance.canvas.measureText(text).getWidth();
		}
	}
	
	override public function begin() {
		canvas.clearRect(0, 0, width, height);
	}
	
	override public function end() {
		
	}
	
	override public function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	override public function drawImage(img : com.ktxsoftware.kha.Image, x : Float, y : Float) {
		canvas.drawImage(cast(img, Image).image, tx + x, ty + y);
	}
	
	override public function drawImage2(image : com.ktxsoftware.kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		try {
			canvas.drawImage(cast(image, Image).image, sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
		}
		catch (ex : Dynamic) {
			
		}
	}
	
	override public function setColor(r : Int, g : Int, b : Int) {
		canvas.strokeStyle = "rgb(" + r + "," + g + "," + b + ")";
		canvas.fillStyle = "rgb(" + r + "," + g + "," + b + ")";
	}
	
	override public function drawRect(x :Float, y : Float, width : Float, height : Float) {
		canvas.rect(tx + x, ty + y, width, height);
	}
	
	override public function fillRect(x : Float, y : Float, width : Float, height : Float) {
		canvas.fillRect(tx + x, ty + y, width, height);
	}

	override public function drawString(text : String, x : Float, y : Float) {
		canvas.fillText(text, tx + x, ty + y);
	}

	override public function setFont(font : com.ktxsoftware.kha.Font) {
		var webfont = cast(font, Font);
		canvas.font = webfont.size + "px " + webfont.name;
	}

	override public function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) {
		canvas.moveTo(tx + x1, ty + y1);
		canvas.lineTo(tx + x2, ty + y2);
		canvas.moveTo(0, 0);
	}

	override public function fillTriangle(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) {
		canvas.beginPath();
		
		canvas.closePath();
		canvas.fill();
	}
}