package com.ktx.kje.backends.android;

import android.graphics.Bitmap;
import com.ktx.kje.Image;

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

	@Override
	public boolean isAlpha(int x, int y) {
		// TODO Auto-generated method stub
		return false;
	}
}