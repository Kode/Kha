package com.ktxsoftware.kha.backends.flash;

import flash.display.Bitmap;
import flash.display.DisplayObject;

class Image implements com.ktxsoftware.kha.Image {
	public var image : Bitmap;
	
	public function new(image : DisplayObject)  {
		this.image = cast(image, Bitmap);
	}
	
	public function getWidth() : Int {
		return Std.int(image.width);
	}
	
	public function getHeight() : Int {
		return Std.int(image.height);
	}
	
	public function isAlpha(x : Int, y : Int) : Bool {
		return true;
	}
}