package kha.psm;

import kha.graphics.TextureFormat;

class Graphics {
	public function new() {
		
	}
	
	public function createTexture(width: Int, height: Int, format: TextureFormat): Image {
		return null; // new Image(width, height, format);
	}
	
	public function vsynced(): Bool {
		return true;
	}
	
	public function refreshRate(): Int {
		return 60;
	}
}
