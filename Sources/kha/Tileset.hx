package kha;

import kha.graphics2.Graphics;

class Tileset {
	public var TILE_WIDTH : Int;
	public var TILE_HEIGHT : Int;
	var xmax : Int;
	var ymax : Int;
	var image : Image;
	var tiles : Array<Tile>;

	public function new(imagename: String, tileWidth: Int, tileHeight: Int, tiles: Array<Tile> = null) {
		TILE_WIDTH = 32;
		TILE_HEIGHT = 32;
		
		this.image = Loader.the.getImage(imagename);
		TILE_WIDTH = tileWidth;
		TILE_HEIGHT = tileHeight;
		xmax = Std.int(image.width / TILE_WIDTH);
		ymax = Std.int(image.height / TILE_HEIGHT);
		if (tiles == null) {
			this.tiles = new Array<Tile>();
			for (i in 0...getLength()) this.tiles.push(new Tile(i, false));
		}
		else this.tiles = tiles;
	}
	
	public function render(g: Graphics, tile: Int, x: Int, y: Int): Void {
		if (tile < 0) return;
		var index = tiles[tile].imageIndex;
		var ytile : Int = Std.int(index / xmax);
		var xtile : Int = index - ytile * xmax;
		g.drawScaledSubImage(image, xtile * TILE_WIDTH, ytile * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT, x, y, TILE_WIDTH, TILE_HEIGHT);
	}
	
	public function tile(index: Int): Tile {
		return tiles[index];
	}

	public function getLength(): Int {
		return xmax * ymax;
	}
}
