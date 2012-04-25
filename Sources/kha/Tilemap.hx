package kha;

class Tilemap {
	var tileset : Tileset;
	var map : Array<Array<Int>>;
	var levelWidth : Int;
	var levelHeight : Int;
	var tileCollision : Array<Bool>;
	
	public function new(imagename : String, tileWidth : Int, tileHeight : Int, map : Array<Array<Int>>, tileCollision : Array<Bool>) {
		tileset = new Tileset(imagename, tileWidth, tileHeight);
		this.map = map;
		this.tileCollision = tileCollision;
		levelWidth = map.length;
		levelHeight = map[0].length;
	}
	
	public function render(painter : Painter, xleft : Int, ytop : Int, width : Int, height : Int) {
		var xstart : Int = Std.int(Math.max(xleft / tileset.TILE_WIDTH, 0));
		var xend : Int = Std.int(Math.min((xleft + width) / tileset.TILE_WIDTH + 1, levelWidth));
		var ystart : Int = Std.int(Math.max(ytop / tileset.TILE_HEIGHT, 0));
		var yend : Int = Std.int(Math.min((ytop + height) / tileset.TILE_HEIGHT + 2, levelHeight));
		for (x in xstart...xend) for (y in ystart...yend) {
			tileset.render(painter, map[x][y], x * tileset.TILE_WIDTH, y * tileset.TILE_HEIGHT);
		}
	}
	
	public function collidesupdown(x1 : Int, x2 : Int, y : Int) : Bool {
		if (y < 0 || y / tileset.TILE_HEIGHT >= levelHeight) return false;
		var xtilestart : Int = Std.int(x1 / tileset.TILE_WIDTH);
		var xtileend : Int = Std.int(x2 / tileset.TILE_WIDTH);
		var ytile : Int = Std.int(y / tileset.TILE_HEIGHT);
		for (xtile in xtilestart...xtileend + 1) if (tileCollision[map[xtile][ytile]]) return true;
		return false;
	}
	
	public function collidesrightleft(x : Int, y1 : Int, y2 : Int) {
		if (x < 0 || x / tileset.TILE_WIDTH >= levelWidth) return true;
		var ytilestart : Int = Std.int(y1 / tileset.TILE_HEIGHT);
		var ytileend : Int = Std.int(y2 / tileset.TILE_HEIGHT);
		var xtile : Int = Std.int(x / tileset.TILE_WIDTH);
		for (ytile in ytilestart...ytileend + 1) {
			if (ytile < 0 || ytile >= levelHeight) continue;
			if (tileCollision[map[xtile][ytile]]) return true;
		}
		return false;
	}
	
	public function collides(x : Int, y : Int) : Bool {
		if (x < 0 || x / tileset.TILE_WIDTH >= levelWidth) return true;
		if (y < 0 || y / tileset.TILE_HEIGHT >= levelHeight) return false;
		
		var value : Int = map[Std.int(x / tileset.TILE_WIDTH)][Std.int(y / tileset.TILE_HEIGHT)];
		
		return tileCollision[value];
	}
	
	private static function round(value : Float) : Int{
		return Math.round(value);
	}
	
	public function collideright(sprite : Sprite) : Bool {
		var rect : Rectangle = sprite.collisionRect();
		var collided : Bool = false;
		if (collidesrightleft(Std.int(rect.x + rect.width), round(rect.y + 1), round(rect.y + rect.height - 1))) {
			sprite.x = Math.floor((rect.x + rect.width) / tileset.TILE_WIDTH) * tileset.TILE_WIDTH - rect.width;
			collided = true;
		}
		return collided;
	}
	
	public function collideleft(sprite : Sprite) : Bool {
		var rect : Rectangle = sprite.collisionRect();
		var collided : Bool = false;
		if (collidesrightleft(Std.int(rect.x), round(rect.y + 1), round(rect.y + rect.height - 1))) {
			sprite.x = (Math.floor(rect.x / tileset.TILE_WIDTH) + 1) * tileset.TILE_WIDTH;
			collided = true;
		}
		return collided;
	}
	
	public function collidedown(sprite : Sprite) : Bool {
		var rect : Rectangle = sprite.collisionRect();
		var collided : Bool = false;
		if (collidesupdown(round(rect.x + 1), round(rect.x + rect.width - 1), Std.int(rect.y + rect.height))) {
			sprite.y = Math.floor((rect.y + rect.height) / tileset.TILE_HEIGHT) * tileset.TILE_HEIGHT - rect.height;
			collided = true;
		}
		return collided;
	}
	
	public function collideup(sprite : Sprite) : Bool {
		var rect : Rectangle = sprite.collisionRect();
		var collided : Bool = false;
		if (collidesupdown(round(rect.x + 1), round(rect.x + rect.width - 1), Std.int(rect.y))) {
			sprite.y = ((Math.floor(rect.y / tileset.TILE_HEIGHT) + 1) * tileset.TILE_HEIGHT);
			collided = true;
		}
		return collided;
	}
	
	public function getWidth() : Int {
		return levelWidth;
	}
	
	public function getHeight() : Int {
		return levelHeight;
	}
	
	public function getTileset() : Tileset {
		return tileset;
	}
}