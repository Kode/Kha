package com.ktxsoftware.kje;

public class Tileset {
	public int TILE_WIDTH = 32;
	public int TILE_HEIGHT = 32;
	int xmax, ymax;
	private Image image;

	public Tileset(String imagename, int tileWidth, int tileHeight) {
		this.image = Loader.getInstance().getImage(imagename);
		TILE_WIDTH = tileWidth;
		TILE_HEIGHT = tileHeight;
		xmax = image.getWidth() / TILE_WIDTH;
		ymax = image.getHeight() / TILE_HEIGHT;
	}

	public void render(Painter painter, int tile, int x, int y) {
		//if (tile == 0 || tile == 1 || tile == 73) return; //mario performance hack
		if (tile == 0) return;
		int ytile = tile / xmax;
		int xtile = tile - ytile * xmax;
		painter.drawImage(image, xtile * TILE_WIDTH, ytile * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT, x, y, TILE_WIDTH, TILE_HEIGHT);
	}

	public int getLength() {
		return xmax * ymax;
	}
}