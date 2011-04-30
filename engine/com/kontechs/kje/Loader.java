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
	public abstract int[][] loadLevel();
}