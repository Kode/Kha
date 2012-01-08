package com.ktxsoftware.kha.backends.cpp;

class Painter extends com.ktxsoftware.kha.Painter {
	var tx : Float;
	var ty : Float;
	
	public function new() {
		tx = 0;
		ty = 0;
	}
	
	public override function begin() {
		
	}
	
	public override function end() {
		
	}
	
	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	public override function drawImage2(image : com.ktxsoftware.kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		
	}
}