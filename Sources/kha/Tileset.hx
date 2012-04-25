package kha;

class Tileset {
	public var TILE_WIDTH : Int;
	public var TILE_HEIGHT : Int;
	var xmax : Int;
	var ymax : Int;
	private var image : Image;

	public function new(imagename : String, tileWidth : Int, tileHeight : Int) {
		TILE_WIDTH = 32;
		TILE_HEIGHT = 32;
		
		this.image = Loader.getInstance().getImage(imagename);
		TILE_WIDTH = tileWidth;
		TILE_HEIGHT = tileHeight;
		xmax = Std.int(image.getWidth() / TILE_WIDTH);
		ymax = Std.int(image.getHeight() / TILE_HEIGHT);
	}

	public function render(painter : Painter, tile : Int, x : Int, y : Int) {
		if (tile != 0) {
			var a = 3;
			++a;
		}
		var ytile : Int = Std.int(tile / xmax);
		var xtile : Int = tile - ytile * xmax;
		painter.drawImage2(image, xtile * TILE_WIDTH, ytile * TILE_HEIGHT, TILE_WIDTH, TILE_HEIGHT, x, y, TILE_WIDTH, TILE_HEIGHT);
	}

	public function getLength() : Int {
		return xmax * ymax;
	}
}