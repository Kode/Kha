package com.ktxsoftware.kje.backends.android;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.nio.Buffer;
import java.nio.IntBuffer;
import java.util.LinkedList;
import java.util.List;

import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import com.ktxsoftware.kje.Image;

class BitmapManager {
	private static List<BitmapImage> images = new LinkedList<BitmapImage>();
	
	static void add(BitmapImage image) {
		images.add(image);
	}
	
	static void touch(BitmapImage image) {
		images.remove(image);
		images.add(image);
		for (int i = 0; i < images.size() - 10; ++i) images.get(i).unload();
	}
}

public class BitmapImage implements Image {
	public static AssetManager assets;
	private String name;
	private WeakReference<Bitmap> bitmap;
	private Bitmap b;
	
	public int tex;
	private Buffer buffer;
	
	public BitmapImage(String name) {
		this.name = name;
		BitmapManager.add(this);
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
		BitmapManager.touch(this);
	}
	
	void unload() {
		b = null;
	}
	
	public Buffer getBuffer() {
		load();
		if (buffer == null) {
			buffer = IntBuffer.allocate(getBitmap().getWidth() * getBitmap().getHeight());
			getBitmap().copyPixelsToBuffer(buffer);
		}
		return buffer;
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