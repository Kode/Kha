package com.ktxsoftware.kha;

class Scene {
	static var instance : Scene;
	
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
	
	public static function getInstance() : Scene {
		return instance;
	}
	
	public function new() {
		instance = this;
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
	
	private function adjustCamX() : Int {
		if (colissionMap != null) {
			var realcamx : Int = Std.int(Math.min(Math.max(0, camx - Game.getInstance().getWidth() / 2), colissionMap.getWidth() * colissionMap.getTileset().TILE_WIDTH - Game.getInstance().getWidth()));
			if (getWidth() < Game.getInstance().getWidth()) realcamx = 0;
			return realcamx;
		}
		else return camx;
	}
	
	private function sort(sprites : Array<Sprite>) {
		sprites.sort(function(arg0 : Sprite, arg1 : Sprite) {
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
			if (sprite.x > camx + Game.getInstance().getWidth()) break;
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
			if (enemies[i].x > camx + Game.getInstance().getWidth()) break;
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
			if (projectiles[i].x > camx + Game.getInstance().getWidth()) break;
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
	
	private function move(sprite : Sprite) {
		sprite.speedx += sprite.accx;
		sprite.speedy += sprite.accy;
		if (sprite.collides) {
			if (sprite.speedy > sprite.maxspeedy) sprite.speedy = sprite.maxspeedy;
			sprite.x += sprite.speedx;
			
			if (colissionMap != null) {
				var rect : Rectangle = sprite.collisionRect();
				if (sprite.speedx > 0) { if (/*colissionMap.collideright(sprite)*/ rect.x + rect.width > 640 - 16) { sprite.x = 640 - 16 - rect.width; sprite.hitFrom(Direction.LEFT); } }
				else if (sprite.speedx < 0) { if (/*colissionMap.collideleft(sprite)*/ rect.x < 16) { sprite.x = 16; sprite.hitFrom(Direction.RIGHT); } }
				sprite.y += sprite.speedy;
				if (sprite.speedy > 0) { if (colissionMap.collidedown(sprite)) { sprite.hitFrom(Direction.UP); sprite.speedy = 0; } }
				else if (sprite.speedy < 0 && sprite.y < 50) { if (colissionMap.collideup(sprite)) sprite.hitFrom(Direction.DOWN); }
			}
		}
		else {
			sprite.x += sprite.speedx;
			sprite.y += sprite.speedy;
		}
	}
	
	public function render(painter : Painter) {
		painter.translate(0, 0);
		painter.setColor(backgroundColor.r, backgroundColor.g, backgroundColor.b);
		painter.clear();
		
		var camx : Int = adjustCamX();
		
		for (i in 0...backgrounds.length) {
			painter.translate(-camx * backgroundSpeeds[i], camy * backgroundSpeeds[i]);
			backgrounds[i].render(painter, Std.int(camx * backgroundSpeeds[i]), 0, Game.getInstance().getWidth(), Game.getInstance().getHeight());
		}
		
		painter.translate(-camx, camy);
		
		for (z in 0...10) {
			var i : Int = 0;
			while (i < sprites.length) {
				if (sprites[i].x + sprites[i].width > camx) break;
				++i;
			}
			while (i < sprites.length) {
				if (sprites[i].x > camx + Game.getInstance().getWidth()) break;
				if (i < sprites.length && sprites[i].z == z) sprites[i].render(painter);
				++i;
			}
		}
		
		for (i in 0...foregrounds.length) {
			painter.translate(-camx * foregroundSpeeds[i], camy * foregroundSpeeds[i]);
			foregrounds[i].render(painter, Std.int(camx * foregroundSpeeds[i]), 0, Game.getInstance().getWidth(), Game.getInstance().getHeight());
		}
	}
	
	public function getWidth() : Float {
		if (colissionMap != null) return colissionMap.getWidth() * colissionMap.getTileset().TILE_WIDTH;
		else return 0;
	}
}