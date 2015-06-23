package android.opengl;

import android.graphics.Bitmap;

extern class GLUtils {
	public static function texImage2D(textype: Int, unknown1: Int, bitmap: Bitmap, unknown2: Int): Void;
	public static function texSubImage2D(target: Int, level: Int, xoffset: Int, yoffset: Int, bitmap: Bitmap, format: Int, type: Int): Void;
}
