package com.ktxsoftware.kje.backends.android;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.IOException;

import android.content.Context;
import android.content.res.AssetManager;

import com.ktxsoftware.kje.Font;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Score;

public class ResourceLoader extends Loader {
	private AssetManager assets;
	
	public ResourceLoader(Context context) {
		this.assets = context.getAssets();
		BitmapImage.assets = assets;
	}
	
	@Override
	public void loadImage(String name) {
		try {
			images.put(name, new BitmapImage(name));
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void loadSound(String name) {
		try {
			sounds.put(name, new AndroidSound(assets.openFd(name + ".wav")));
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public void loadMusic(String name) {
		try {
			musics.put(name, new AndroidMusic(assets.openFd(name + ".ogg")));
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void loadMap(String name) {
		try {
			int[][] map;
			DataInputStream stream = new DataInputStream(new BufferedInputStream(assets.open(name)));
			int levelWidth = stream.readInt();
			int levelHeight = stream.readInt();
			map = new int[levelWidth][levelHeight];
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				map[x][y] = stream.readInt();
			}
			maps.put(name, map);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public Font loadFont(String name, int style, int size) {
		return new AndroidFont(name);
	}

	@Override
	public void loadHighscore() {
		//TODO evtl
	}

	@Override
	public void saveHighscore(Score score) {
		//TODO evtl
	}

	@Override
	protected void loadXml(String filename) {
		try {
		    xmls.put(filename, new AndroidNode(assets.open(filename)));
		} catch (IOException e) {
		    e.printStackTrace();
		}
	}

	@Override
	public void setNormalCursor() {
	}

	@Override
	public void setHandCursor() {
	}
}