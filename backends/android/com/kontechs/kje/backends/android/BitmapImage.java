package com.kontechs.kje.backends.android;

import android.graphics.Bitmap;
import com.kontechs.kje.Image;

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