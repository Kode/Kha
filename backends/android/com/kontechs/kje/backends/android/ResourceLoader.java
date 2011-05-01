package com.kontechs.kje.backends.android;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.IOException;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.BitmapFactory;

import com.kontechs.kje.Image;
import com.kontechs.kje.Loader;
import com.kontechs.kje.Music;
import com.kontechs.kje.Sound;
import com.kontechs.kje.TileProperty;

public class ResourceLoader extends Loader {
	private AssetManager assets;
	
	public ResourceLoader(Context context) {
		this.assets = context.getAssets();
	}
	
	@Override
	public Image loadImage(String filename) {
		try {
			return new BitmapImage(BitmapFactory.decodeStream(assets.open(filename + ".png")));
		}
		catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public Sound loadSound(String filename) {
		try {
			return new AndroidSound(assets.openFd(filename + ".wav"));
		}
		catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public Music loadMusic(String filename) {
		try {
			return new AndroidMusic(assets.openFd(filename + ".ogg"));
		}
		catch (IOException e) {
			return null;
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
	public void loadTileset(String name) {
		TileProperty[] array_elements = null;
		DataInputStream stream_elements = null;
		try {
			stream_elements = new DataInputStream(new BufferedInputStream(assets.open(name + ".settings")));

			array_elements = new TileProperty[stream_elements.readInt()];
			for(int i = 0;i<array_elements.length;i++){
				array_elements[i] = new TileProperty();
			}
			for (int i = 0; i < array_elements.length; i++) {
				array_elements[i].setCollides(stream_elements.readBoolean());
				array_elements[i].setEnemy(stream_elements.readBoolean());
				array_elements[i].setEnemyTyp(stream_elements.readUTF());
				array_elements[i].setSeasonMode(stream_elements.readInt());
				array_elements[i].setLinkedTile(stream_elements.readInt());
			}
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		finally {
			try {
				stream_elements.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		tilesets.put(name, array_elements);
	}

	@Override
	public void loadHighscore() {
		
	}
}