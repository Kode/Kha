package kha;

import kha.graphics2.Graphics;
#if !cs
#if !java
import kha.graphics4.Graphics2;
#end
#end
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
	public static function targetRect(width: Int, height: Int, destination: Canvas, rotation: ScreenRotation): TargetRectangle {
		var scalex: Float;
		var scaley: Float;
		var scalew: Float;
		var scaleh: Float;
		var scale: Float;
		switch (rotation) {
		case ScreenRotation.RotationNone:
			if (width / height > destination.width / destination.height) {
				scale = destination.width / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0;
				scaley = (destination.height - scaleh) * 0.5;
			}
			else {
				scale = destination.height / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destination.width - scalew) * 0.5;
				scaley = 0;
			}
		case ScreenRotation.Rotation90:
			if (width / height > destination.height / destination.width) {
				scale = destination.height / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destination.width - scaleh) * 0.5 + scaleh;
				scaley = 0;
			}
			else {
				scale = destination.width / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0 + scaleh;
				scaley = (destination.height - scalew) * 0.5;
			}
		case ScreenRotation.Rotation180:
			if (width / height > destination.width / destination.height) {
				scale = destination.width / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0 + scalew;
				scaley = (destination.height - scaleh) * 0.5 + scaleh;
			}
			else {
				scale = destination.height / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destination.width - scalew) * 0.5 + scalew;
				scaley = 0 + scaleh;
			}
		case ScreenRotation.Rotation270:
			if (width / height > destination.height / destination.width) {
				scale = destination.height / width;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = (destination.width - scaleh) * 0.5;
				scaley = 0 + scalew;
			}
			else {
				scale = destination.width / height;
				scalew = width * scale;
				scaleh = height * scale;
				scalex = 0;
				scaley = (destination.height - scalew) * 0.5 + scalew;
			}
		}
		return new TargetRectangle(scalex, scaley, scalew, scaleh, scale, rotation);
	}
	
	public static function transformX(x: Int, y: Int, source: Image, destination: Canvas, rotation: ScreenRotation): Int {
		var targetRect = targetRect(source.width, source.height, destination, rotation);
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
	
	public static function transformY(x: Int, y: Int, source: Image, destination: Canvas, rotation: ScreenRotation): Int {
		var targetRect = targetRect(source.width, source.height, destination, rotation);
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
	
	public static function scale(source: Image, destination: Canvas, rotation: ScreenRotation): Void {
		var g = destination.g2;
		g.transformation = getScaledTransformation(source.width, source.height, destination, rotation);
		g.color = Color.White;
		g.opacity = 1;
		g.drawImage(source, 0, 0);
	}
	
	public static function getScaledTransformation(width: Int, height: Int, destination: Canvas, rotation: ScreenRotation): Matrix3 {
		var rect = targetRect(width, height, destination, rotation);
		var sf = rect.scaleFactor;
		var transformation = new Matrix3([sf,  0, rect.x,
										   0, sf, rect.y,
										   0,  0, 1]);
		switch (rotation) {
		case RotationNone:
		case Rotation90:
			transformation = transformation * Matrix3.rotation(Math.PI / 2);
		case Rotation180:
			transformation = transformation * Matrix3.rotation(Math.PI);
		case Rotation270:
			transformation = transformation * Matrix3.rotation(Math.PI * 3 / 2);
		}
		return transformation;
	}
}
