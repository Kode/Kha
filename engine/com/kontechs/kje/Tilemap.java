package com.kontechs.kje;

public class Tilemap {
	private Tileset tileset;
	private int[][] map;
	private int levelWidth;
	private int levelHeight;
	private TileProperty[] properties;

	public Tilemap(int[][] map, TileProperty[] properties) {
		tileset = new Tileset();
		this.map = map;
		this.properties = properties;
		levelWidth = map.length;
		levelHeight = map[0].length;
	}
	
	public void render(Painter painter, int xleft, int ytop, int width, int height) {
		int xstart = Math.max(xleft / Tileset.TILE_WIDTH, 0);
		int xend = Math.min((xleft + width) / Tileset.TILE_WIDTH + 1, levelWidth);
		int ystart = Math.max(ytop / Tileset.TILE_HEIGHT, 0);
		int yend = Math.min((ytop + height) / Tileset.TILE_HEIGHT + 1, levelHeight);
		for (int x = xstart; x < xend; ++x) for (int y = ystart; y < yend; ++y) {
			tileset.render(painter, map[x][y], x * Tileset.TILE_WIDTH, y * Tileset.TILE_HEIGHT);
		}
	}
	
	public boolean collidesupdown(int x1, int x2, int y) {
		if (y < 0 || y / Tileset.TILE_HEIGHT >= levelHeight) return false;
		int xtilestart = x1 / Tileset.TILE_WIDTH;
		int xtileend = x2 / Tileset.TILE_WIDTH;
		int ytile = y / Tileset.TILE_HEIGHT;
		for (int xtile = xtilestart; xtile <= xtileend; ++xtile) {
			int value = map[xtile][ytile];
			if (properties[value].isCollides()) return true;
		}
		return false;
	}
	
	public boolean collidesrightleft(int x, int y1, int y2) {
		if (x < 0 || x / Tileset.TILE_WIDTH >= levelWidth) return true;
		int ytilestart = y1 / Tileset.TILE_HEIGHT;
		int ytileend = y2 / Tileset.TILE_HEIGHT;
		int xtile = x / Tileset.TILE_WIDTH;
		for (int ytile = ytilestart; ytile <= ytileend; ++ytile) {
			if (ytile < 0 || ytile >= levelHeight) continue;
			int value = map[xtile][ytile];
			if (properties[value].isCollides()) return true;
		}
		return false;
	}
	
	public boolean collides(int x, int y) {
		if (x < 0 || x / Tileset.TILE_WIDTH >= levelWidth) return true;
		if (y < 0 || y / Tileset.TILE_HEIGHT >= levelHeight) return false;
		
		int value = map[x / Tileset.TILE_WIDTH][y / Tileset.TILE_HEIGHT];
		
		return properties[value].isCollides();
	}
	
	public boolean collideright(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		//if (collides(rect.x + rect.width, rect.y + 1) || collides(rect.x + rect.width, rect.y + rect.height - 1)) {
		if (collidesrightleft(rect.x + rect.width, rect.y + 1, rect.y + rect.height - 1)) {
			sprite.x = (rect.x + rect.width) / Tileset.TILE_WIDTH * Tileset.TILE_WIDTH - rect.width;
			collided = true;
		}
		return collided;
	}
	
	public boolean collideleft(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		//if (collides(rect.x, rect.y + 1) || collides(rect.x, rect.y + rect.height - 1)) {
		if (collidesrightleft(rect.x, rect.y + 1, rect.y + rect.height - 1)) {
			sprite.x = (rect.x / Tileset.TILE_WIDTH + 1) * Tileset.TILE_WIDTH;
			collided = true;
		}
		return collided;
	}
	
	public boolean collidedown(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		//if (collides(rect.x + 1, rect.y + rect.height) || collides(rect.x + rect.width - 1, rect.y + rect.height)) {
		if (collidesupdown(rect.x + 1, rect.x + rect.width - 1, rect.y + rect.height)) {
			sprite.y = (rect.y + rect.height) / Tileset.TILE_HEIGHT * Tileset.TILE_HEIGHT - rect.height;
			collided = true;
		}
		return collided;
	}
	
	public boolean collideup(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		//if (collides(rect.x + 1, rect.y) || collides(rect.x + rect.width - 1, rect.y)) {
		if (collidesupdown(rect.x + 1, rect.x + rect.width - 1, rect.y)) {
			sprite.y = (rect.y / Tileset.TILE_HEIGHT + 1) * Tileset.TILE_HEIGHT;
			collided = true;
		}
		return collided;
	}
	
	public int getWidth() {
		return levelWidth;
	}
}