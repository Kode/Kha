package kha;

import kha.graphics2.Graphics;
#if !cs
#if !java
import kha.graphics4.Graphics2;
#end
#end
import kha.math.FastMatrix3;
import kha.math.Matrix3;
import kha.math.Matrix4;

class TargetRectangle {
	public var x: Float;
	public var y: Float;
	public var width: Float;
	public var height: Float;
	public var scaleFactor: Float;
	public var rotation: ScreenRotation;
	
	public function new(x: Float, y: Float, w: Float, h: Float, s: Float, r: ScreenRotation) {
		this.x = x;
		this.y = y;
		this.width = w;
		this.height = h;
		this.scaleFactor = s;
		this.rotation = r;
	}
}

class Scaler {
	public static function targetRect(width: Int, height: Int, destinationWidth: Int, destinationHeight: Int, rotation: ScreenRotation): TargetRectangle {
		var scalex: Float;
		var scaley: Float;
		var scalew: Float;
		var scaleh: Float;
		var scale: Float;
		switch (rotation) {
		case ScreenRotation.RotationNone:
			if (width / height > destinationWidth / destinationHeight) {
				scale = destinationWidth / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0;
				scaley = (destinationHeight - scaleh) * 0.5;
			}
			else {
				scale = destinationHeight / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destinationWidth - scalew) * 0.5;
				scaley = 0;
			}
		case ScreenRotation.Rotation90:
			if (width / height > destinationHeight / destinationWidth) {
				scale = destinationHeight / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destinationWidth - scaleh) * 0.5 + scaleh;
				scaley = 0;
			}
			else {
				scale = destinationWidth / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0 + scaleh;
				scaley = (destinationHeight - scalew) * 0.5;
			}
		case ScreenRotation.Rotation180:
			if (width / height > destinationWidth / destinationHeight) {
				scale = destinationWidth / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0 + scalew;
				scaley = (destinationHeight - scaleh) * 0.5 + scaleh;
			}
			else {
				scale = destinationHeight / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destinationWidth - scalew) * 0.5 + scalew;
				scaley = 0 + scaleh;
			}
		case ScreenRotation.Rotation270:
			if (width / height > destinationHeight / destinationWidth) {
				scale = destinationHeight / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destinationWidth - scaleh) * 0.5;
				scaley = 0 + scalew;
			}
			else {
				scale = destinationWidth / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0;
				scaley = (destinationHeight - scalew) * 0.5 + scalew;
			}
		}
		return new TargetRectangle(scalex, scaley, scalew, scaleh, scale, rotation);
	}
	
	public static function transformXDirectly(x: Int, y: Int, sourceWidth: Int, sourceHeight: Int, destinationWidth: Int, destinationHeight: Int, rotation: ScreenRotation): Int {
		var targetRect = targetRect(sourceWidth, sourceHeight, destinationWidth, destinationHeight, rotation);
		switch (targetRect.rotation) {
		case ScreenRotation.RotationNone:
			return Std.int((x - targetRect.x) / targetRect.scaleFactor);
		case ScreenRotation.Rotation90:
			return Std.int((y - targetRect.y) / targetRect.scaleFactor);
		case ScreenRotation.Rotation180:
			return Std.int((targetRect.x - x) / targetRect.scaleFactor);
		case ScreenRotation.Rotation270:
			return Std.int((targetRect.y - y) / targetRect.scaleFactor);
		}
	}
	
	/**
	 * Transform the X value from the given position in the source to a position in the destination canvas.
	 *
	 * @param x					The X position.
	 * @param y					The Y position.
	 * @param source			The source image.
	 * @param destination		The destination canvas.
	 * @param rotation			The screen rotation.
	 */
	public static function transformX(x: Int, y: Int, source: Image, destination: Canvas, rotation: ScreenRotation): Int {
		return transformXDirectly(x, y, source.width, source.height, destination.width, destination.height, rotation);
	}
	
	public static function transformYDirectly(x: Int, y: Int, sourceWidth: Int, sourceHeight: Int, destinationWidth: Int, destinationHeight: Int, rotation: ScreenRotation): Int {
		var targetRect = targetRect(sourceWidth, sourceHeight, destinationWidth, destinationHeight, rotation);
		switch (targetRect.rotation) {
		case ScreenRotation.RotationNone:
			return Std.int((y - targetRect.y) / targetRect.scaleFactor);
		case ScreenRotation.Rotation90:
			return Std.int((targetRect.x - x) / targetRect.scaleFactor);
		case ScreenRotation.Rotation180:
			return Std.int((targetRect.y - y) / targetRect.scaleFactor);
		case ScreenRotation.Rotation270:
			return Std.int((x - targetRect.x) / targetRect.scaleFactor);
		}
	}

	/**
	 * Transform the Y value from the given position in the source to a position in the destination canvas.
	 *
	 * @param x					The X position.
	 * @param y					The Y position.
	 * @param source			The source image.
	 * @param destination		The destination canvas.
	 * @param rotation			The screen rotation.
	 */
	public static function transformY(x: Int, y: Int, source: Image, destination: Canvas, rotation: ScreenRotation): Int {
		return transformYDirectly(x, y, source.width, source.height, destination.width, destination.height, rotation);
	}
	
	public static function scale(source: Image, destination: Canvas, rotation: ScreenRotation): Void {
		var g = destination.g2;
		g.transformation = getScaledTransformation(source.width, source.height, destination.width, destination.height, rotation);
		g.color = Color.White;
		g.opacity = 1;
		g.drawImage(source, 0, 0);
	}
	
	public static function getScaledTransformation(width: Int, height: Int, destinationWidth: Int, destinationHeight: Int, rotation: ScreenRotation): FastMatrix3 {
		var rect = targetRect(width, height, destinationWidth, destinationHeight, rotation);
		var sf = rect.scaleFactor;
		var transformation = new FastMatrix3(sf,  0, rect.x,
										   0, sf, rect.y,
										   0,  0, 1);
		switch (rotation) {
		case RotationNone:
		case Rotation90:
			transformation = transformation.multmat(FastMatrix3.rotation(Math.PI / 2));
		case Rotation180:
			transformation = transformation.multmat(FastMatrix3.rotation(Math.PI));
		case Rotation270:
			transformation = transformation.multmat(FastMatrix3.rotation(Math.PI * 3 / 2));
		}
		return transformation;
	}
}
