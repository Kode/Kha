package com.kontechs.kje;

public abstract class Game {
	private Scene scene;
	
	public Game() {
		scene = new Scene();
		init();
	}
	
	public abstract void init();
	
	public void update() {
		scene.update();
	}
	
	public void render(Painter painter) {
		scene.render(painter);
	}
	
	public abstract void key(KeyEvent event);
}