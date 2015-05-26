package kha.graphics1;

import kha.Color;

interface Graphics {
	public function begin(): Void;
	public function end(): Void;
	public function setPixel(x: Int, y: Int, color: Color): Void;
}
