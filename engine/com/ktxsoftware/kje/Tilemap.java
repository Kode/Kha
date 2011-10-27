package com.ktxsoftware.kje;

public class Tilemap {
	private Tileset tileset;
	private int[][] map;
	private int levelWidth;
	private int levelHeight;
	private boolean[] tileCollision;
	
	public Tilemap(String imagename, int tileWidth, int tileHeight, int[][] map, boolean[] tileCollision) {
		tileset = new Tileset(imagename, tileWidth, tileHeight);
		this.map = map;
		this.tileCollision = tileCollision;
		levelWidth = map.length;
		levelHeight = map[0].length;
	}
	
	public void render(Painter painter, int xleft, int ytop, int width, int height) {
		int xstart = Math.max(xleft / tileset.TILE_WIDTH, 0);
		int xend = Math.min((xleft + width) / tileset.TILE_WIDTH + 1, levelWidth);
		int ystart = Math.max(ytop / tileset.TILE_HEIGHT, 0);
		int yend = Math.min((ytop + height) / tileset.TILE_HEIGHT + 1, levelHeight);
		for (int x = xstart; x < xend; ++x) for (int y = ystart; y < yend; ++y) {
			tileset.render(painter, map[x][y], x * tileset.TILE_WIDTH, y * tileset.TILE_HEIGHT);
		}
	}
	
	public boolean collidesupdown(int x1, int x2, int y) {
		if (y < 0 || y / tileset.TILE_HEIGHT >= levelHeight) return false;
		int xtilestart = x1 / tileset.TILE_WIDTH;
		int xtileend = x2 / tileset.TILE_WIDTH;
		int ytile = y / tileset.TILE_HEIGHT;
		for (int xtile = xtilestart; xtile <= xtileend; ++xtile) if (tileCollision[map[xtile][ytile]]) return true;
		return false;
	}
	
	public boolean collidesrightleft(int x, int y1, int y2) {
		if (x < 0 || x / tileset.TILE_WIDTH >= levelWidth) return true;
		int ytilestart = y1 / tileset.TILE_HEIGHT;
		int ytileend = y2 / tileset.TILE_HEIGHT;
		int xtile = x / tileset.TILE_WIDTH;
		for (int ytile = ytilestart; ytile <= ytileend; ++ytile) {
			if (ytile < 0 || ytile >= levelHeight) continue;
			if (tileCollision[map[xtile][ytile]]) return true;
		}
		return false;
	}
	
	public boolean collides(int x, int y) {
		if (x < 0 || x / tileset.TILE_WIDTH >= levelWidth) return true;
		if (y < 0 || y / tileset.TILE_HEIGHT >= levelHeight) return false;
		
		int value = map[x / tileset.TILE_WIDTH][y / tileset.TILE_HEIGHT];
		
		return tileCollision[value];
	}
	
	private static int round(double value) {
		return (int)Math.round(value);
	}
	
	public boolean collideright(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		if (collidesrightleft((int)(rect.x + rect.width), round(rect.y + 1), round(rect.y + rect.height - 1))) {
			sprite.x = Math.floor((rect.x + rect.width) / tileset.TILE_WIDTH) * tileset.TILE_WIDTH - rect.width;
			collided = true;
		}
		return collided;
	}
	
	public boolean collideleft(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		if (collidesrightleft((int)rect.x, round(rect.y + 1), round(rect.y + rect.height - 1))) {
			sprite.x = (Math.floor(rect.x / tileset.TILE_WIDTH) + 1) * tileset.TILE_WIDTH;
			collided = true;
		}
		return collided;
	}
	
	public boolean collidedown(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		if (collidesupdown(round(rect.x + 1), round(rect.x + rect.width - 1), (int)(rect.y + rect.height))) {
			sprite.y = Math.floor((rect.y + rect.height) / tileset.TILE_HEIGHT) * tileset.TILE_HEIGHT - rect.height;
			collided = true;
		}
		return collided;
	}
	
	public boolean collideup(Sprite sprite) {
		Rectangle rect = sprite.collisionRect();
		boolean collided = false;
		if (collidesupdown(round(rect.x + 1), round(rect.x + rect.width - 1), (int)rect.y)) {
			sprite.y = ((Math.floor(rect.y / tileset.TILE_HEIGHT) + 1) * tileset.TILE_HEIGHT);
			collided = true;
		}
		return collided;
	}
	
	public int getWidth() {
		return levelWidth;
	}
	
	public Tileset getTileset() {
		return tileset;
	}
}