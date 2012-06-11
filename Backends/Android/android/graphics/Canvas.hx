package android.graphics;

extern class Canvas {
	public function drawRect(x : Single, y : Single, width : Single, height : Single, paint : Paint) : Void;
	public function drawText(text : String, x : Single, y : Single, paint : Paint) : Void;
	public function drawBitmap(bitmap : Bitmap, x : Single, y : Single, paint : Paint) : Void;
	public function drawLine(x1 : Single, y1 : Single, x2 : Single, y2 : Single, paint : Paint) : Void;
}