package com.kontechs.kje;

public abstract class Loader {
	private static Loader instance;
	
	public static void init(Loader loader) {
		instance = loader;
	}
	
	public static Loader getInstance() {
		return instance;
	}
	
	public abstract Image loadImage(String filename);
	public abstract Sound loadSound(String filename);
	public abstract Music loadMusic(String filename);
	
	public abstract void setMaps(String[] names);
	public abstract void setTilesets(String[] names);
	public abstract void load();
	
	public abstract int[][] getMap(String name);
	public abstract TileProperty[] getTileset(String tilesPropertyName);
	
	public abstract void loadHighscore();
}