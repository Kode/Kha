package android.graphics;

extern class Paint {
	public function new() : Void;
	public function setFilterBitmap(b : Bool) : Void;
	public function setSubpixelText(b : Bool) : Void;
	public function setAntiAlias(b : Bool) : Void;
	public function setColor(color : Color) : Void;
	public function setTextSize(size : Single) : Void;
	public function measureText(text : String) : Float;
	public function setTypeface(face : Typeface) : Void;
}