package com.ktxsoftware.kha.backends.js;

class Painter extends com.ktxsoftware.kha.Painter {
	var canvas : Dynamic;
	var tx : Float;
	var ty : Float;
	
	public function new(canvas : Dynamic) {
		this.canvas = canvas;
		tx = 0;
		ty = 0;
	}
	
	public override function begin() {
		canvas.clearRect(0, 0, 600, 520);
	}
	
	public override function end() {
		
	}
	
	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	public override function drawImage2(image : com.ktxsoftware.kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		canvas.drawImage(cast(image, Image).image, sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
	}
}