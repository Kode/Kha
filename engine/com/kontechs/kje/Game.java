package com.kontechs.kje;

public abstract class Game {
	private static Game instance;
	private Scene scene;
	
	public static Game getInstance() {
		return instance;
	}
	
	public Game(String lvl_name, String tilesPropertyName) {
		instance = this;
		scene = new Scene();
		preInit(lvl_name, tilesPropertyName);
	}
	
	public abstract void preInit(String lvl_name, String tilesPropertyName); //Used to configure the Loader
	public abstract void postInit(); //Called by the Loader when finished
	
	public void update() {
		scene.update();
	}
	
	public void render(Painter painter) {
		scene.render(painter);
	}
	
	public abstract void key(KeyEvent event);
	public void charKey(char c) { }
}