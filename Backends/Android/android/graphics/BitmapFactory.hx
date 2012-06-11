package android.graphics;

import java.io.InputStream;

extern class BitmapFactory {
	public static function decodeStream(stream : InputStream) : Bitmap;
}