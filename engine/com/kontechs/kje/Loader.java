package com.kontechs.kje;

import java.util.Iterator;
import java.util.Set;

public abstract class Loader {
	private static Loader instance;
	protected java.util.Map<String, int[][]> maps = new java.util.HashMap<String, int[][]>();
	protected java.util.Map<String, TileProperty[]> tilesets = new java.util.HashMap<String, TileProperty[]>();
	protected int loadcount;
	
	public static void init(Loader loader) {
		instance = loader;
	}
	
	public static Loader getInstance() {
		return instance;
	}
	
	public void setTilesets(String[] names) {
		tilesets.clear();
		for (int i = 0; i < names.length; ++i) tilesets.put(names[i], null);
		loadcount += names.length;
	}

	public void setMaps(String[] names) {
		maps.clear();
		for (int i = 0; i < names.length; ++i) maps.put(names[i], null);
		loadcount += names.length;
	}
	
	public int[][] getMap(String name) {
		return maps.get(name);
	}

	public TileProperty[] getTileset(String tilesPropertyName) {
		return tilesets.get(tilesPropertyName);
	}
	
	public void load() {
		Set<String> mapnames = maps.keySet();
		for (Iterator<String> it = mapnames.iterator(); it.hasNext(); ) loadMap(it.next());
		Set<String> tilesetnames = tilesets.keySet();
		for (Iterator<String> it = tilesetnames.iterator(); it.hasNext(); ) loadTileset(it.next());
	}
	
	public abstract Image loadImage(String filename);
	public abstract Sound loadSound(String filename);
	public abstract Music loadMusic(String filename);
	public abstract void loadHighscore();
	protected abstract void loadMap(String name);
	protected abstract void loadTileset(String name);
}