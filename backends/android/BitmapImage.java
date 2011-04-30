package de.hsharz.game;

import android.graphics.Bitmap;
import de.hsharz.game.engine.Image;

public class BitmapImage implements Image {
	Bitmap bitmap;
	
	public BitmapImage(Bitmap bitmap) {
		this.bitmap = bitmap;
	}
	
	public Bitmap getBitmap() {
		return bitmap;
	}
	
	@Override
	public int getWidth() {
		return bitmap.getWidth();
	}

	@Override
	public int getHeight() {
		return bitmap.getHeight();
	}
}