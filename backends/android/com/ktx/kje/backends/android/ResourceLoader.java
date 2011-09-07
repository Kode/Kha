package com.ktx.kje.backends.android;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.IOException;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.BitmapFactory;

import com.ktx.kje.Font;
import com.ktx.kje.Loader;
import com.ktx.kje.Score;
import com.ktx.kje.TileProperty;

public class ResourceLoader extends Loader {
	private AssetManager assets;
	
	public ResourceLoader(Context context) {
		this.assets = context.getAssets();
	}
	
	@Override
	public void loadImage(String name) {
		try {
			images.put(name, new BitmapImage(BitmapFactory.decodeStream(assets.open(name + ".png"))));
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
	public Font loadFont(String name, int style, int size) {
		return new AndroidFont(name);
	}

	@Override
	public void loadHighscore() {
		
	}

	@Override
	public void saveHighscore(Score score) {
		
	}

	@Override
	protected void loadXml(String filename) {
		
	}

	@Override
	public void setNormalCursor() {
		
	}

	@Override
	public void setHandCursor() {
		
	}
}