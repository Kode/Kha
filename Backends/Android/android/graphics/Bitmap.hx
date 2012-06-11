package android.graphics;

import java.nio.Buffer;

extern class Bitmap {
	public function getWidth() : Int;
	public function getHeight() : Int;
	public function getPixel(x : Int, y : Int) : Int;
	public function copyPixelsToBuffer(buffer : Buffer) : Void;
}