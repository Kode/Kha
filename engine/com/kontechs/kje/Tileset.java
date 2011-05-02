package com.kontechs.kje;

public class Tileset {
	public static final int TILE_WIDTH = 32;
	public static final int TILE_HEIGHT = 32;
	int xmax, ymax;
	private Image image;

	public Tileset() {
		this.image = Loader.getInstance().getImage("tiles");
		xmax = image.getWidth() / TILE_WIDTH;
		ymax = image.getHeight() / TILE_HEIGHT;
	}

	public void render(Painter painter, int tile, int x, int y) {
		int ytile = tile / xmax;
		int xtile = tile - ytile * xmax;
		painter.drawImage(image, xtile * TILE_WIDTH, ytile * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT, x, y, TILE_WIDTH, TILE_HEIGHT);
	}

	public int getLength() {
		return xmax * ymax;
	}
}