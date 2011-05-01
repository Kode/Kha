package com.kontechs.kje;

public abstract class Game {
	private Scene scene;
	
	public Game(String lvl_name, String tilesPropertyName) {
		scene = new Scene();
		init(lvl_name, tilesPropertyName);
	}
	
	public abstract void init(String lvl_name, String tilesPropertyName);
	
	public void update() {
		scene.update();
	}
	
	public void render(Painter painter) {
		scene.render(painter);
	}
	
	public abstract void key(KeyEvent event);
}