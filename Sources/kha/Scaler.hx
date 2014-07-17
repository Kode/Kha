package kha;

import kha.graphics2.Graphics;

class Scaler {
	public static function scale(source: Image, destination: Graphics): Void {
		destination.drawImage(source, 0, 0);
	}
}
