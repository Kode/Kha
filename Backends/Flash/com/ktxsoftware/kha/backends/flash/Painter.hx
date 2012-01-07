package com.ktxsoftware.kha.backends.flash;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

class Painter extends com.ktxsoftware.kha.Painter {
	var graphics : Graphics;
	var tx : Float;
	var ty : Float;
	var matrix : Matrix;
	
	public function new() {
		tx = 0;
		ty = 0;
		matrix = new Matrix();
	}
	
	public function setGraphics(graphics : Graphics) {
		this.graphics = graphics;
	}
	
	public override function begin() {
		graphics.clear();
	}
	
	public override function end() {
		
	}
	
	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	public override function drawImage(img : com.ktxsoftware.kha.Image, x : Float, y : Float) {
		var image : Image = cast(img, Image);
		
	}
	
	public override function drawImage2(img : com.ktxsoftware.kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		var image : Image = cast(img, Image);
		matrix.tx = tx + dx - sx;
		matrix.ty = ty + dy - sy;
		graphics.beginBitmapFill(image.image.bitmapData, matrix);
		graphics.drawRect(tx + dx, ty + dy, dw, dh);
		graphics.endFill();
	}
}