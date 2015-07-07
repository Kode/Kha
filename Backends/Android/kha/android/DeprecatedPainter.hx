package kha.android;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;

class DeprecatedPainter extends kha.Painter {
	var c : Canvas;
	var paint : Paint;
	var tx : Float;
	var ty : Float;
	var width : Int;
	var height : Int;
	
	public function new(c : Canvas, width : Int, height : Int) {
		this.c = c;
		this.width = width;
		this.height = height;
		paint = new Paint();
		paint.setFilterBitmap(true);
		paint.setSubpixelText(true);
		paint.setAntiAlias(true);
	}
	
	function getFactor() : Float{
		if (width / height > kha.Game.getInstance().getWidth() / kha.Game.getInstance().getHeight())
			return height / kha.Game.getInstance().getHeight();
		else
			return width / kha.Game.getInstance().getWidth();
	}
	
	function getXOffset() : Float {
		if (width / height > kha.Game.getInstance().getWidth() / kha.Game.getInstance().getHeight())
			return width / 2 - kha.Game.getInstance().getWidth() * getFactor() / 2;
		else
			return 0;
	}
	
	function getYOffset() : Float {
		if (width / height > kha.Game.getInstance().getWidth() / kha.Game.getInstance().getHeight())
			return 0;
		else
			return height / 2 - kha.Game.getInstance().getHeight() * getFactor() / 2;
	}
	
	function adjustX(x : Float) : Float {
		return x * getFactor();
	}
	
	function adjustY(y : Float) : Float {
		return y * getFactor();
	}
	
	public function adjustXPos(x : Float) : Float {
		return adjustX(x) + getXOffset();
	}
	
	public function adjustYPos(y : Float) : Float {
		return adjustY(y) + getYOffset();
	}
	
	public function adjustXPosInv(x : Float) : Float {
		return (x - getXOffset()) / getFactor();
	}
	
	public function adjustYPosInv(y : Float) : Float {
		return (y - getYOffset()) / getFactor();
	}
	
	override public function drawImage(img : kha.Image, x : Float, y : Float) : Void {
		c.drawBitmap(cast(img, Image).getBitmap(), adjustXPos(round(x + tx)), adjustYPos(round(y + ty)), paint);
	}
	
	@:functionBody('
		c.drawBitmap(((Image)img).getBitmap(),
			new android.graphics.Rect(round(sx), round(sy), round(sx + sw), round(sy + sh)),
			new android.graphics.RectF((float)adjustXPos(round(tx + dx)), (float)adjustYPos(round(ty + dy)), (float)adjustXPos(round(tx + dx + dw)), (float)adjustYPos(round(ty + dy + dh))), paint);
	')
	override public function drawImage2(img : kha.Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) {
		
	}
	
	override public function setColor(r : Int, g : Int, b : Int) : Void {
		paint.setColor(android.graphics.Color.argb(255, r, g, b));
	}

	override public function fillRect(x : Float, y : Float, width : Float, height : Float) : Void {
		//paint.setStyle(Paint.Style.FILL);
		c.drawRect(adjustXPos(x + tx), adjustYPos(y + ty), adjustXPos(x + width + tx), adjustYPos(y + width + ty), paint);
	}

	override public function translate(x : Float, y : Float) : Void {
		tx = x;
		ty = y;
	}

	override public function drawRect(x : Float, y : Float, width : Float, height : Float) : Void {
		//paint.setStyle(Paint.Style.STROKE);
		c.drawRect(adjustXPos(x + tx), adjustYPos(y + ty), adjustXPos(x + width + tx), adjustYPos(y + width + ty), paint);
	}

	override public function drawString(text : String, x : Float, y : Float) : Void {
		c.drawText(text, adjustXPos(x + tx), adjustYPos(y + ty), paint);
	}
	
	function round(value : Float) : Int{
		return Math.round(value);
	}

	override public function setFont(font : kha.Font) {
		var afont : Font = cast(font, Font);
		//paint.setTypeface(Typeface.create(afont.name, Typeface.NORMAL));
		paint.setTextSize(afont.size * getFactor());
	}

	override public function drawChars(text : String, offset : Int, length : Int, x : Float, y : Float) {
		drawString(text.substr(offset, length), x, y);
	}

	override public function drawLine(x1 : Float, y1 : Float, x2 : Float, y2 : Float) : Void {
		c.drawLine(adjustXPos(x1 + tx), adjustYPos(y1 + ty), adjustXPos(x2 + tx), adjustYPos(y2 + ty), paint);
	}

	override public function fillTriangle(x1 : Float, y1 : Float, x2 : Float, y2 : Float, x3 : Float, y3 : Float) : Void {
		
	}
	
	override public function clear() : Void {
		//paint.setStyle(Paint.Style.FILL);
		c.drawRect(0, 0, width, height, paint);
	}
}