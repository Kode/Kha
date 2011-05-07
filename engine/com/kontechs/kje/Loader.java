package com.kontechs.kje;

import java.util.Iterator;
import java.util.Set;

public abstract class Loader {
	private static Loader instance;
	protected java.util.Map<String, int[][]> maps = new java.util.HashMap<String, int[][]>();
	protected java.util.Map<String, TileProperty[]> tilesets = new java.util.HashMap<String, TileProperty[]>();
	protected java.util.Map<String, Image> images = new java.util.HashMap<String, Image>();
	protected java.util.Map<String, Sound> sounds = new java.util.HashMap<String, Sound>();
	protected java.util.Map<String, Music> musics = new java.util.HashMap<String, Music>();
	protected int loadcount;
	
	public static void init(Loader loader) {
		instance = loader;
	}
	
	public static Loader getInstance() {
		return instance;
	}
	
	public void setImages(String[] names) {
		images.clear();
		for (int i = 0; i < names.length; ++i) images.put(names[i], null);
		loadcount += names.length;
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
	
	public void setMusics(String[] names) {
		musics.clear();
		for (int i = 0; i < names.length; ++i) musics.put(names[i], null);
		loadcount += names.length;
	}
	
	public void setSounds(String[] names) {
		sounds.clear();
		for (int i = 0; i < names.length; ++i) sounds.put(names[i], null);
		loadcount += names.length;
	}
	
	public int[][] getMap(String name) {
		return maps.get(name);
	}

	public TileProperty[] getTileset(String name) {
		return tilesets.get(name);
	}
	
	public Image getImage(String name) {
		if (!images.containsKey(name)) java.lang.System.err.println("Could not find image " + name + ".");
		return images.get(name);
	}
	
	public Music getMusic(String name) {
		return musics.get(name);
	}
	
	public Sound getSound(String name) {
		return sounds.get(name);
	}
	
	public void load() {
		loadStarted();
		
		Set<String> imagenames = images.keySet();
		for (Iterator<String> it = imagenames.iterator(); it.hasNext(); ) loadImage(it.next());
		Set<String> musicnames = musics.keySet();
		for (Iterator<String> it = musicnames.iterator(); it.hasNext(); ) loadMusic(it.next());
		Set<String> soundnames = sounds.keySet();
		for (Iterator<String> it = soundnames.iterator(); it.hasNext(); ) loadSound(it.next());
		Set<String> mapnames = maps.keySet();
		for (Iterator<String> it = mapnames.iterator(); it.hasNext(); ) loadMap(it.next());
		Set<String> tilesetnames = tilesets.keySet();
		for (Iterator<String> it = tilesetnames.iterator(); it.hasNext(); ) loadTileset(it.next());
	}
	
	protected void loadStarted() { }
	
	public abstract void loadHighscore();
	
	protected abstract void loadImage(String filename);
	protected abstract void loadMap(String name);
	protected abstract void loadTileset(String name);
	protected abstract void loadSound(String filename);
	protected abstract void loadMusic(String filename);
}