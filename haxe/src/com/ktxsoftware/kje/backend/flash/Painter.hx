package com.ktxsoftware.kje.backend.flash;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;

class Painter extends com.ktxsoftware.kje.Painter {
	var graphics : Graphics;
	var backBuffer : BitmapData;
	var tx : Float;
	var ty : Float;
	
	public function new() {
		backBuffer = new BitmapData(600, 520, false);
		tx = 0;
		ty = 0;
	}
	
	public function setGraphics(graphics : Graphics) {
		this.graphics = graphics;
	}
	
	public override function begin() {
		backBuffer.fillRect(backBuffer.rect, 0xffffff);
	}
	
	public override function end() {
		graphics.beginBitmapFill(backBuffer);
		graphics.drawRect(0, 0, 600, 520);
		graphics.endFill();
	}
	
	public override function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	public override function drawImage(img : com.ktxsoftware.kje.Image, x : Float, y : Float) {
		var image : Image = cast(img, Image);
		
	}
	
	public override function drawImage2(img : com.ktxsoftware.kje.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		var image : Image = cast(img, Image);
		backBuffer.copyPixels(image.image.bitmapData, new Rectangle(sx, sy, sw, sh), new Point(tx + dx, ty + dy));
		//trace("draw " + sx + " " + sy + " "  + sw + " "  + sh + " "  + " at " + (tx + dx) + " - " + (ty + dy));
	}
}