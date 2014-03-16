package kha.java;

import kha.graphics.TextureFormat;
import kha.graphics.Usage;

class Graphics {
	public function new() {
		
	}
	
	public function createTexture(width: Int, height: Int, format: TextureFormat, usage: Usage): Image {
		return null;//new Image(width, height, format); //FIXME: Correct this
	}

	public function maxTextureSize(): Int {
		return 4096;
	}
	
	public function vsynced(): Bool {
		return true;
	}
	
	public function refreshRate(): Int {
		return 60;
	}
}
