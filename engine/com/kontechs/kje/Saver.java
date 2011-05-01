package com.kontechs.kje;

public abstract class Saver {
	private static Saver instance;
	
	public static void init(Saver saver) {
		instance = saver;
	}
	
	public static Saver getInstance() {
		return instance;
	}
	
	public abstract void saveHighscore();
}
