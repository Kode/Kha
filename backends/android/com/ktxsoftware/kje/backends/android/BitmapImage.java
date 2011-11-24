package com.ktxsoftware.kje.backends.android;

import java.io.IOException;
import java.lang.ref.WeakReference;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.ktxsoftware.kje.Image;

public class BitmapImage implements Image {
	public static AssetManager assets;
	private String name;
	private WeakReference<Bitmap> bitmap;
	private Bitmap b;
	
	public BitmapImage(String name) {
		this.name = name;
	}
	
	private void load() {
		if (bitmap != null && bitmap.get() != null) return;
		try {
			b = BitmapFactory.decodeStream(assets.open(name));
			bitmap = new WeakReference<Bitmap>(b);
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public Bitmap getBitmap() {
		load();
		return bitmap.get();
	}
	
	@Override
	public int getWidth() {
		load();
		return bitmap.get().getWidth();
	}

	@Override
	public int getHeight() {
		load();
		return bitmap.get().getHeight();
	}

	@Override
	public boolean isAlpha(int x, int y) {
		load();
		return (bitmap.get().getPixel(x, y) >> 24) != 0;
	}
}