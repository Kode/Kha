package kha;

import kha.graphics2.Graphics;
#if !cs
#if !java
import kha.graphics4.Graphics2;
#end
#end
import kha.math.Matrix3;
import kha.math.Matrix4;

class Scaler {
	public static function scale(source: Image, destination: Canvas, rotation: ScreenRotation): Void {
		var scalex: Float;
		var scaley: Float;
		var scalew: Float;
		var scaleh: Float;
		if (rotation == ScreenRotation.RotationNone || rotation == ScreenRotation.Rotation180) {
			if (source.width / source.height > destination.width / destination.height) {
				var scale = destination.width / source.width;
				scalew = source.width * scale;
				scaleh = source.height * scale;
				scalex = 0;
				scaley = (destination.height - scaleh) * 0.5;
			}
			else {
				var scale = destination.height / source.height;
				scalew = source.width * scale;
				scaleh = source.height * scale;
				scalex = (destination.width - scalew) * 0.5;
				scaley = 0;
			}
		}
		else if (rotation == ScreenRotation.Rotation90) {
			if (source.width / source.height > destination.height / destination.width) {
				var scale = destination.height / source.width;
				scalew = source.width * scale;
				scaleh = source.height * scale;
				scalex = (destination.width - scaleh) * 0.5 + scaleh;
				scaley = 0;
			}
			else {
				var scale = destination.width / source.height;
				scalew = source.width * scale;
				scaleh = source.height * scale;
				scalex = 0 + scaleh;
				scaley = (destination.height - scalew) * 0.5;
			}
		}
		else { // ScreenRotation.Rotation270
			if (source.width / source.height > destination.height / destination.width) {
				var scale = destination.height / source.width;
				scalew = source.width * scale;
				scaleh = source.height * scale;
				scalex = (destination.width - scaleh) * 0.5;
				scaley = 0 + scalew;
			}
			else {
				var scale = destination.width / source.height;
				scalew = source.width * scale;
				scaleh = source.height * scale;
				scalex = 0;
				scaley = (destination.height - scalew) * 0.5 + scalew;
			}
		}
		
		destination.g2.color = Color.White;
		destination.g2.opacity = 1;
		
		switch (rotation) {
		case RotationNone:
		#if !cs
		#if !java
			if (Std.is(destination.g2, Graphics2)) {
				var imagePainter = cast(destination.g2, Graphics2).imagePainter;
				if (destination.g4.renderTargetsInvertedY()) {
					imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, 0, Sys.pixelHeight, 0.1, 1000));
					imagePainter.drawImageScale(source, 0, source.realHeight - source.height, source.width, source.height, scalex, scaley, scalex + scalew, scaley + scaleh, 1, Color.White);
				}
				else {
					imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
					imagePainter.drawImageScale(source, 0, 0, source.width, source.height, scalex, scaley, scalex + scalew, scaley + scaleh, 1, Color.White);
				}
				imagePainter.end();
				imagePainter.setProjection(Matrix4.orthogonalProjection(0, source.realWidth, source.realHeight, 0, 0.1, 1000));
			}
			else {
		#end
		#end
				destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
		#if !cs
		#if !java
			}
		#end
		#end
		case Rotation90:
			destination.g2.transformation = Matrix3.translation(scalex, scaley) * Matrix3.rotation(Math.PI / 2) * Matrix3.translation( -scalex, -scaley);
		#if !cs
		#if !java
			if (Std.is(destination.g2, Graphics2)) {
				var imagePainter = cast(destination.g2, Graphics2).imagePainter;
				if (destination.g4.renderTargetsInvertedY()) {
					imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, 0, Sys.pixelHeight, 0.1, 1000));
					destination.g2.drawScaledSubImage(source, 0, source.realHeight - source.height, source.width, source.height, scalex, scaley, scalew, scaleh);
				}
				else {
					imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
					destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
				}
				imagePainter.end();
				imagePainter.setProjection(Matrix4.orthogonalProjection(0, source.realWidth, source.realHeight, 0, 0.1, 1000));
			}
			else {
		#end
		#end
				destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
		#if !cs
		#if !java
			}
		#end
		#end
			destination.g2.transformation = Matrix3.identity();
		case Rotation180:
			destination.g2.transformation = Matrix3.translation(scalex + scalew / 2, scaley + scaleh / 2) * Matrix3.rotation(Math.PI) * Matrix3.translation( -scalex - scalew / 2, -scaley - scaleh / 2);
		#if !cs
		#if !java
			if (Std.is(destination.g2, Graphics2)) {
				var imagePainter = cast(destination.g2, Graphics2).imagePainter;
				if (destination.g4.renderTargetsInvertedY()) {
					imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, 0, Sys.pixelHeight, 0.1, 1000));
					destination.g2.drawScaledSubImage(source, 0, source.realHeight - source.height, source.width, source.height, scalex, scaley, scalew, scaleh);
				}
				else {
					imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
					destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
				}
				imagePainter.end();
				imagePainter.setProjection(Matrix4.orthogonalProjection(0, source.realWidth, source.realHeight, 0, 0.1, 1000));
			}
			else {
		#end
		#end
				destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
		#if !cs
		#if !java
			}
		#end
		#end
			destination.g2.transformation = Matrix3.identity();
		case Rotation270:
			destination.g2.transformation = Matrix3.translation(scalex, scaley) * Matrix3.rotation(Math.PI * 3 / 2) * Matrix3.translation( -scalex, -scaley);
		#if !cs
		#if !java
			if (Std.is(destination.g2, Graphics2)) {
				var imagePainter = cast(destination.g2, Graphics2).imagePainter;
				if (destination.g4.renderTargetsInvertedY()) {
					imagePainter.setProjection(Matrix4.orthogonalProjection(Sys.pixelWidth, 0, Sys.pixelHeight, 0, 0.1, 1000));
					destination.g2.drawScaledSubImage(source, 0, source.realHeight - source.height, source.width, source.height, scalex, scaley, scalew, scaleh);
				}
				else {
					imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
					destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
				}
				imagePainter.end();
				imagePainter.setProjection(Matrix4.orthogonalProjection(0, source.realWidth, source.realHeight, 0, 0.1, 1000));
			}
			else {
		#end
		#end
				destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
		#if !cs
		#if !java
			}
		#end
		#end
			destination.g2.transformation = Matrix3.identity();
		}
	}
}
