package com.ktxsoftware.kje;

public abstract class Game {
	private static Game instance;
	private Scene scene;
	private int width, height;
	
	public static Game getInstance() {
		return instance;
	}
	
	public Game(String lvl_name, String tilesPropertyName, int width, int height) {
		instance = this;
		this.width = width;
		this.height = height;
		scene = new Scene();
	}
	
	public int getWidth() {
		return width;
	}
	
	public int getHeight() {
		return height;
	}
	
	public abstract void init(); //Called by the Loader when finished
	
	public void update() {
		scene.update();
	}
	
	public void render(Painter painter) {
		scene.render(painter);
	}
	
	public abstract void key(KeyEvent event);
	public void charKey(char c) { }
	
	public void mouseDown(int x, int y) { }
	public void mouseUp(int x, int y) { }
	public void mouseMove(int x, int y) { }
}