package com.ktxsoftware.kha.backends.js;

import js.Dom;

class Image implements com.ktxsoftware.kha.Image {
	public var image : js.Image;
	
	public function new(image : js.Image) {
		this.image = image;
	}
	
	public function getWidth() : Int {
		return image.width;
	}
	
	public function getHeight() : Int {
		return image.height;
	}
	
	public function isAlpha(x : Int, y : Int) : Bool {
		return true;
	}
}