package kha;

class Scene {
	private static var instance : Scene;
	
	var colissionMap : Tilemap;
	var backgrounds : Array<Tilemap>;
	var foregrounds : Array<Tilemap>;
	var backgroundSpeeds : Array<Float>;
	var foregroundSpeeds : Array<Float>;
	//var lastUpdatedSprites : Array<Sprite>;
	//var updatedSprites : Array<Sprite>;
	
	var heroes : Array<Sprite>;
	var sprites : Array<Sprite>;
	var enemies : Array<Sprite>;
	var projectiles : Array<Sprite>;
	
	var backgroundColor : Color;
	
	public var camx : Int;
	public var camy : Int;
	
	public static var the(getThe, null): Scene;
	
	private static function getThe(): Scene {
		if (instance == null) instance = new Scene();
		return instance;
	}
	
	function new() {
		sprites = new Array<Sprite>();
		heroes = new Array<Sprite>();
		enemies = new Array<Sprite>();
		projectiles = new Array<Sprite>();
		backgrounds = new Array<Tilemap>();
		foregrounds = new Array<Tilemap>();
		backgroundSpeeds = new Array<Float>();
		foregroundSpeeds = new Array<Float>();
		//lastUpdatedSprites = new Array<Sprite>();
		//updatedSprites = new Array<Sprite>();
		backgroundColor = new Color(0, 0, 0);
		camx = 0;
		camy = 0;
	}
	
	public function clear() {
		colissionMap = null;
		clearTilemaps();
		heroes = new Array<Sprite>();
		enemies = new Array<Sprite>();
		sprites = new Array<Sprite>();
	}
	
	public function clearTilemaps() {
		backgrounds = new Array<Tilemap>();
		foregrounds = new Array<Tilemap>();
		backgroundSpeeds = new Array<Float>();
		foregroundSpeeds = new Array<Float>();
	}
	
	public function setBackgroundColor(color : Color) {
		backgroundColor = color;
	}
	
	public function getEnemies() : Array<Sprite> {
		return enemies;
	}
	
	public function addBackgroundTilemap(tilemap : Tilemap, speed : Float) {
		backgrounds.push(tilemap);
		backgroundSpeeds.push(speed);
	}
	
	public function addForegroundTilemap(tilemap : Tilemap, speed : Float) {
		foregrounds.push(tilemap);
		foregroundSpeeds.push(speed);
	}
	
	public function setColissionMap(tilemap : Tilemap) {
		colissionMap = tilemap;
	}
	
	public function addHero(sprite : Sprite) {
		heroes.push(sprite);
		sprites.push(sprite);
	}
	
	public function addEnemy(sprite : Sprite) {
		enemies.push(sprite);
		sprites.push(sprite);
	}
	
	public function addProjectile(sprite : Sprite) {
		projectiles.push(sprite);
		sprites.push(sprite);
	}
	
	public function removeEnemy(sprite : Sprite) {
		enemies.remove(sprite);
		sprites.remove(sprite);
	}
	
	public function removeHero(sprite : Sprite) {
		heroes.remove(sprite);
		sprites.remove(sprite);
	}
	
	public function removeProjectile(sprite : Sprite) {
		projectiles.remove(sprite);
		sprites.remove(sprite);
	}
	
	function adjustCamX() : Int {
		if (colissionMap != null) {
			var realcamx : Int = Std.int(Math.min(Math.max(0, camx - Game.the.width / 2), colissionMap.getWidth() * colissionMap.getTileset().TILE_WIDTH - Game.the.width));
			if (getWidth() < Game.the.width) realcamx = 0;
			return realcamx;
		}
		else return camx;
	}
	
	function adjustCamY() : Int {
		if (colissionMap != null) {
			var realcamy : Int = Std.int(Math.min(Math.max(0, camy - Game.the.height / 2), colissionMap.getHeight() * colissionMap.getTileset().TILE_HEIGHT - Game.the.height));
			if (getHeight() < Game.the.height) realcamy = 0;
			return realcamy;
		}
		else return camy;
	}
	
	function sort(sprites : Array<Sprite>) {
		if (sprites.length == 0) return;
		sprites.sort(function(arg0: Sprite, arg1: Sprite) {
			if (arg0.x < arg1.x) return -1;
			else if (arg0.x == arg1.x) return 0;
			else return 1;
		});
	}
	
	public function update() {
		var camx : Int = adjustCamX();
		sort(sprites);
		var i : Int = 0;
		while (i < sprites.length) {
			if (sprites[i].x + sprites[i].width > camx) break;
			++i;
		}
		while (i < sprites.length) {
			var sprite : Sprite = sprites[i];
			if (sprite.x > camx + Game.the.width) break;
			//updatedSprites.push(sprite);
			sprite.update();
			move(sprite);
			++i;
		}
		/*for (sprite in updatedSprites) {
			sprite.update();
			move(sprite);
		}
		for (sprite in lastUpdatedSprites) {
			//if (!updatedSprites...contains(sprite)) sprite.outOfView();
		}
		lastUpdatedSprites = updatedSprites;
		updatedSprites = new Array<Sprite>();*/
		
		sort(heroes);
		sort(enemies);
		sort(projectiles);
		i = 0;
		
		while (i < enemies.length) {
			if (enemies[i].x + enemies[i].width > camx) break;
			++i;
		}
		while (i < enemies.length) {
			if (enemies[i].x > camx + Game.the.width) break;
			var rect1 : Rectangle = enemies[i].collisionRect();
			for (i2 in 0...heroes.length) {
				var rect2 : Rectangle = heroes[i2].collisionRect();
				if (rect1.collision(rect2)) {
					heroes[i2].hit(enemies[i]);
					if (i < enemies.length && i2 < heroes.length) enemies[i].hit(heroes[i2]);
				}
			}
			for (i2 in 0...projectiles.length) {
				var rect2 : Rectangle = projectiles[i2].collisionRect();
				if (rect1.collision(rect2)) {
					projectiles[i2].hit(enemies[i]);
					if (i < enemies.length && i2 < projectiles.length) enemies[i].hit(projectiles[i2]);
				}
			}
			++i;
		}
		
		i = 0;
		while (i < projectiles.length) {
			if (projectiles[i].x + projectiles[i].width > camx) break;
			++i;
		}
		while (i < projectiles.length) {
			if (projectiles[i].x > camx + Game.the.width) break;
			var rect1 : Rectangle = projectiles[i].collisionRect();
			for (i2 in 0...heroes.length) {
				var rect2 : Rectangle = heroes[i2].collisionRect();
				if (rect1.collision(rect2)) {
					heroes[i2].hit(projectiles[i]);
					if (i < projectiles.length && i2 < heroes.length) projectiles[i].hit(heroes[i2]);
				}
			}
			++i;
		}
	}
	
	//Bresenhahm
	function line(xstart : Float, ystart : Float, xend : Float, yend : Float, sprite : Sprite) : Void {
		var x0 = round(xstart);
		var y0 = round(ystart);
		var x1 = round(xend);
		var y1 = round(yend);
		sprite.x = x0;
		sprite.y = y0;
		var dx = Math.abs(x1 - x0);
		var dy = Math.abs(y1 - y0);
		var sx : Int;
		var sy : Int;
		if (x0 < x1) sx = 1; else sx = -1;
		if (y0 < y1) sy = 1; else sy = -1;
		var err = dx - dy;

		while (true) {
			//setPixel(x0,y0)
			if (x0 == x1 && y0 == y1) {
				sprite.x = xend;
				sprite.y = yend;
				break;
			}
			var e2 = 2 * err;
			if (e2 > -dy) {
				err -= dy;
				x0 += sx;
				sprite.x = x0;
				if (colissionMap.collides(sprite)) {
					sprite.y -= 1;
					if (!colissionMap.collides(sprite)) {
						continue;
					}
					else {
						sprite.y -= 1;
						if (!colissionMap.collides(sprite)) {
							continue;
						}
						else {
							sprite.y -= 1;
							if (!colissionMap.collides(sprite)) {
								continue;
							}
							sprite.y += 1;
						}
						sprite.y += 1;
					}
					sprite.y += 1;
					sprite.x -= sx;
					if (sx < 0) sprite.hitFrom(Direction.RIGHT);
					else sprite.hitFrom(Direction.LEFT);
					while (true) {
						if (y0 == y1) {
							sprite.y = yend;
							return;
						}
						y0 += sy;
						sprite.y = y0;
						if (colissionMap.collides(sprite)) {
							sprite.y -= sy;
							if (sy < 0) sprite.hitFrom(Direction.DOWN);
							else sprite.hitFrom(Direction.UP);
							return;
						}
					}
					return;
				}
			}
			if (e2 < dx) {
				err += dx;
				y0 += sy; 
				sprite.y = y0;
				if (colissionMap.collides(sprite)) {
					sprite.y -= sy;
					if (sy < 0) sprite.hitFrom(Direction.DOWN);
					else sprite.hitFrom(Direction.UP);
					while (true) {
						if (x0 == x1) {
							sprite.x = xend;
							return;
						}
						x0 += sx;
						sprite.x = x0;
						if (colissionMap.collides(sprite)) {
							sprite.y -= 1;
							if (!colissionMap.collides(sprite)) {
								continue;
							}
							else {
								sprite.y -= 1;
								if (!colissionMap.collides(sprite)) {
									continue;
								}
								else {
									sprite.y -= 1;
									if (!colissionMap.collides(sprite)) {
										continue;
									}
									sprite.y += 1;
								}
								sprite.y += 1;
							}
							sprite.y += 1;
							sprite.x -= sx;
							if (sx < 0) sprite.hitFrom(Direction.RIGHT);
							else sprite.hitFrom(Direction.LEFT);
							return;
						}
					}
					return;
				}
			}
		}
	}
	
	static function round(value : Float) : Int {
		return Math.round(value);
	}
	
	function move(sprite : Sprite) {
		sprite.speedx += sprite.accx;
		sprite.speedy += sprite.accy;
		if (sprite.speedy > sprite.maxspeedy) sprite.speedy = sprite.maxspeedy;
		if (sprite.collides) {
			var xaim = sprite.x + sprite.speedx;
			var yaim = sprite.y + sprite.speedy;
			var xstart = sprite.x;
			var ystart = sprite.y;
			sprite.x = xaim;
			sprite.y = yaim;
			if (colissionMap != null && colissionMap.collides(sprite)) {
				line(xstart, ystart, xaim, yaim, sprite);
			}

			/*sprite.x += sprite.speedx;
			
			if (colissionMap != null) {
				if (sprite.speedx > 0) { if (colissionMap.collideright(sprite)) sprite.hitFrom(Direction.LEFT); }
				else if (sprite.speedx < 0) { if (colissionMap.collideleft(sprite)) sprite.hitFrom(Direction.RIGHT); }
				sprite.y += sprite.speedy;
				if (sprite.speedy > 0) { if (colissionMap.collidedown(sprite)) sprite.hitFrom(Direction.UP); }
				else if (sprite.speedy < 0) { if (colissionMap.collideup(sprite)) sprite.hitFrom(Direction.DOWN); }
			}*/
			
			//Bubble Dragons Hack
			/*if (colissionMap != null) {
				var rect : Rectangle = sprite.collisionRect();
				if (sprite.speedx > 0) { if (rect.x + rect.width > 640 - 16) { sprite.x = 640 - 16 - rect.width; sprite.hitFrom(Direction.LEFT); } }
				else if (sprite.speedx < 0) { if (rect.x < 16) { sprite.x = 16; sprite.hitFrom(Direction.RIGHT); } }
				sprite.y += sprite.speedy;
				if (sprite.speedy > 0) { if (colissionMap.collidedown(sprite)) { sprite.hitFrom(Direction.UP); sprite.speedy = 0; } }
				else if (sprite.speedy < 0 && sprite.y < 50) { if (colissionMap.collideup(sprite)) sprite.hitFrom(Direction.DOWN); }
			}*/
		}
		else {
			sprite.x += sprite.speedx;
			sprite.y += sprite.speedy;
		}
	}
	
	public function render(painter : Painter) {
		painter.translate(0, 0);
		//painter.setColor(backgroundColor.r, backgroundColor.g, backgroundColor.b);
		//painter.clear();
		
		var camx : Int = adjustCamX();
		var camy : Int = adjustCamY();
		
		for (i in 0...backgrounds.length) {
			painter.translate(Math.round(-camx * backgroundSpeeds[i]), Math.round(-camy * backgroundSpeeds[i]));
			backgrounds[i].render(painter, Std.int(camx * backgroundSpeeds[i]), Std.int(camy * backgroundSpeeds[i]), Game.the.width, Game.the.height);
		}
		
		painter.translate(-camx, -camy);
		
		for (z in 0...10) {
			var i : Int = 0;
			while (i < sprites.length) {
				if (sprites[i].x + sprites[i].width > camx) break;
				++i;
			}
			while (i < sprites.length) {
				if (sprites[i].x > camx + Game.the.width) break;
				if (i < sprites.length && sprites[i].z == z) sprites[i].render(painter);
				++i;
			}
		}
		
		for (i in 0...foregrounds.length) {
			painter.translate(Math.round(-camx * foregroundSpeeds[i]), Math.round(-camy * foregroundSpeeds[i]));
			foregrounds[i].render(painter, Std.int(camx * foregroundSpeeds[i]), Std.int(camy * foregroundSpeeds[i]), Game.the.width, Game.the.height);
		}
	}
	
	public function getWidth() : Float {
		if (colissionMap != null) return colissionMap.getWidth() * colissionMap.getTileset().TILE_WIDTH;
		else return 0;
	}
	
	public function getHeight() : Float {
		if (colissionMap != null) return colissionMap.getHeight() * colissionMap.getTileset().TILE_HEIGHT;
		else return 0;
	}
}