package kha;

import kha.graphics2.Graphics;
import kha.math.Matrix3;

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
		
		switch (rotation) {
		case RotationNone:
			//if (Sys.graphics.renderTargetsInvertedY()) {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, 0, Sys.pixelHeight, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, renderTexture.realHeight - renderTexture.height, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, null, 1, Color.White);
			//}
			//else {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, 0, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, null, 1, Color.White);
			//}
			destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
		case Rotation90:
			//if (Sys.graphics.renderTargetsInvertedY()) {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, 0, Sys.pixelHeight, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, renderTexture.realHeight - renderTexture.height, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, new Rotation(new Vector2(0, 0), Math.PI / 2), 1, Color.White);
			//}
			//else {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, 0, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, new Rotation(new Vector2(0, 0), Math.PI / 2), 1, Color.White);
			//}
			destination.g2.transformation = Matrix3.translation(scalex, scaley) * Matrix3.rotation(Math.PI / 2) * Matrix3.translation(-scalex, -scaley);
			destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
			destination.g2.transformation = Matrix3.identity();
		case Rotation180:
			//if (Sys.graphics.renderTargetsInvertedY()) {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, 0, Sys.pixelHeight, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, renderTexture.realHeight - renderTexture.height, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, new Rotation(new Vector2(scalew / 2, scaleh / 2), Math.PI), 1, Color.White);
			//}
			//else {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, 0, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, new Rotation(new Vector2(scalew / 2, scaleh / 2), Math.PI), 1, Color.White);
			//}
			destination.g2.transformation = Matrix3.translation(scalex + scalew / 2, scaley + scaleh / 2) * Matrix3.rotation(Math.PI) * Matrix3.translation(-scalex - scalew / 2, -scaley - scaleh / 2);
			destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
			destination.g2.transformation = Matrix3.identity();
		case Rotation270:
			//if (Sys.graphics.renderTargetsInvertedY()) {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(Sys.pixelWidth, 0, Sys.pixelHeight, 0, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, renderTexture.realHeight - renderTexture.height, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, new Rotation(new Vector2(0, 0), Math.PI * 3 / 2), 1, Color.White);
			//}
			//else {
			//	imagePainter.setProjection(Matrix4.orthogonalProjection(0, Sys.pixelWidth, Sys.pixelHeight, 0, 0.1, 1000));
			//	imagePainter.drawImage2(renderTexture, 0, 0, renderTexture.width, renderTexture.height, scalex, scaley, scalew, scaleh, new Rotation(new Vector2(0, 0), Math.PI * 3 / 2), 1, Color.White);
			//}
			destination.g2.transformation = Matrix3.translation(scalex, scaley) * Matrix3.rotation(Math.PI * 3 / 2) * Matrix3.translation(-scalex, -scaley);
			destination.g2.drawScaledImage(source, scalex, scaley, scalew, scaleh);
			destination.g2.transformation = Matrix3.identity();
		}
	}
}
