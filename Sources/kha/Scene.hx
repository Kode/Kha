package kha;

import haxe.ds.ArraySort;
import kha.graphics2.Graphics;
import kha.math.Matrix3;
import kha.math.Vector2;

class Scene {
	private static var instance : Scene;
	
	var collisionLayer: CollisionLayer;
	var backgrounds : Array<Tilemap>;
	var foregrounds : Array<Tilemap>;
	var backgroundSpeeds : Array<Float>;
	var foregroundSpeeds : Array<Float>;
	//var lastUpdatedSprites : Array<Sprite>;
	//var updatedSprites : Array<Sprite>;
	
	var sprites : Array<Sprite>;
	
	var backgroundColor : Color;
	
	public var camx(default, set): Int;
	public var camy(default, set): Int;
	public var screenOffsetX: Int;
	public var screenOffsetY: Int;
	
	private var dirtySprites: Bool = false;
	
	public static var the(get, null): Scene;
	
	private static function get_the(): Scene {
		if (instance == null) instance = new Scene();
		return instance;
	}
	
	function new() {
		sprites = new Array<Sprite>();
		backgrounds = new Array<Tilemap>();
		foregrounds = new Array<Tilemap>();
		backgroundSpeeds = new Array<Float>();
		foregroundSpeeds = new Array<Float>();
		//lastUpdatedSprites = new Array<Sprite>();
		//updatedSprites = new Array<Sprite>();
		backgroundColor = Color.fromBytes(0, 0, 0);
		camx = 0;
		camy = 0;
	}
	
	public function clear() {
		collisionLayer = null;
		clearTilemaps();
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

	public function addBackgroundTilemap(tilemap : Tilemap, speed : Float) {
		backgrounds.push(tilemap);
		backgroundSpeeds.push(speed);
	}
	
	public function addForegroundTilemap(tilemap : Tilemap, speed : Float) {
		foregrounds.push(tilemap);
		foregroundSpeeds.push(speed);
	}
	
	public function setColissionMap(tilemap: Tilemap) {
		collisionLayer = new CollisionLayer(tilemap);
	}
	
	public function addHero(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addHero(sprite);
		sprites.push(sprite);
	}
	
	public function addEnemy(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addEnemy(sprite);
		sprites.push(sprite);
	}
	
	public function addProjectile(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addProjectile(sprite);
		sprites.push(sprite);
	}
	
	public function addOther(sprite: Sprite) {
		sprite.removed = false;
		if (collisionLayer != null) collisionLayer.addOther(sprite);
		sprites.push(sprite);
	}

	public function removeHero(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
		//if (collisionLayer != null) collisionLayer.removeHero(sprite);
		//sprites.remove(sprite);
	}
	
	public function removeEnemy(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
		//if (collisionLayer != null) collisionLayer.removeEnemy(sprite);
		//sprites.remove(sprite);
	}
	
	public function removeProjectile(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
		//if (collisionLayer != null) collisionLayer.removeProjectile(sprite);
		//sprites.remove(sprite);
	}
	
	public function removeOther(sprite: Sprite) {
		sprite.removed = true;
		dirtySprites = true;
	}
	
	public function getHero(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getHero(index);
	}
	
	public function getEnemy(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getEnemy(index);
	}
	
	public function getProjectile(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getProjectile(index);
	}
	
	public function getOther(index: Int): Sprite {
		if (collisionLayer == null) return null;
		else return collisionLayer.getOther(index);
	}
	
	public function countHeroes(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countHeroes();
	}
	
	public function countEnemies(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countEnemies();
	}

	public function countProjectiles(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countProjectiles();
	}

	public function countOthers(): Int {
		if (collisionLayer == null) return 0;
		else return collisionLayer.countOthers();
	}
	
	function set_camx(newcamx: Int): Int {
		camx = newcamx;
		if (collisionLayer != null) {
			screenOffsetX = Std.int(Math.min(Math.max(0, camx - Game.the.width / 2), collisionLayer.getMap().getWidth() * collisionLayer.getMap().getTileset().TILE_WIDTH - Game.the.width));
			if (getWidth() < Game.the.width) screenOffsetX = 0;
		}
		else screenOffsetX = camx;
		return camx;
	}
	
	//public var camyHack: Int = 0;
	
	function set_camy(newcamy: Int): Int {
		camy = newcamy;
		if (collisionLayer != null) {
			screenOffsetY = Std.int(Math.min(Math.max(0, camy - Game.the.height / 2), collisionLayer.getMap().getHeight() * collisionLayer.getMap().getTileset().TILE_HEIGHT /*+ camyHack*/ - Game.the.height));
			if (getHeight() < Game.the.height) screenOffsetY = 0;
		}
		else screenOffsetY = camy;
		return camy;
	}
	
	function sort(sprites : Array<Sprite>) {
		if (sprites.length == 0) return;
		ArraySort.sort(sprites, function(arg0: Sprite, arg1: Sprite) {
			if (arg0.x < arg1.x) return -1;
			else if (arg0.x == arg1.x) return 0;
			else return 1;
		});
	}
	
	public function collidesPoint(point: Vector2): Bool {
		return collisionLayer != null && collisionLayer.collidesPoint(point);
	}
	
	public function collidesSprite(sprite: Sprite): Bool {
		return collisionLayer != null && collisionLayer.collidesSprite(sprite);
	}
	
	private function cleanSprites(): Void {
		if (!dirtySprites) return;
		var found = true;
		while (found) {
			found = false;
			for (sprite in sprites) {
				if (sprite.removed) {
					sprites.remove(sprite);
					found = true;
				}
			}
		}
		if (collisionLayer != null) collisionLayer.cleanSprites();
	}
	
	public function update(): Void {
		cleanSprites();
		if (collisionLayer != null) {
			collisionLayer.advance(screenOffsetX, screenOffsetX + Game.the.width);
		}
		cleanSprites();
		/*var xleft = screenOffsetX;
		var xright = screenOffsetX + Game.the.width;
		var i: Int = 0;
		while (i < sprites.length) {
			if (sprites[i].x + sprites[i].width > xleft) break;
			++i;
		}
		while (i < sprites.length) {
			var sprite: Sprite = sprites[i];
			if (sprite.x > xright) break;
			sprite.update();
			++i;
		}*/
		for (sprite in sprites) sprite.update();
		cleanSprites();
	}

	public function render(g: Graphics) {
		g.transformation = Matrix3.identity();
		g.color = backgroundColor;
		g.clear();
		
		for (i in 0...backgrounds.length) {
			g.transformation = Matrix3.translation(Math.round(-screenOffsetX * backgroundSpeeds[i]), Math.round(-screenOffsetY * backgroundSpeeds[i]));
			//painter.translate(Math.round(-screenOffsetX * backgroundSpeeds[i]), Math.round(-screenOffsetY * backgroundSpeeds[i]));
			backgrounds[i].render(g, Std.int(screenOffsetX * backgroundSpeeds[i]), Std.int(screenOffsetY * backgroundSpeeds[i]), Game.the.width, Game.the.height);
		}
		
		g.transformation = Matrix3.translation(-screenOffsetX, -screenOffsetY);
		//painter.translate(-screenOffsetX, -screenOffsetY);
		
		sort(sprites);
		
		for (z in 0...10) {
			var i : Int = 0;
			while (i < sprites.length) {
				if (sprites[i].x + sprites[i].width > screenOffsetX) break;
				++i;
			}
			while (i < sprites.length) {
				if (sprites[i].x > screenOffsetX + Game.the.width) break;
				if (i < sprites.length && sprites[i].z == z) sprites[i].render(g);
				++i;
			}
		}
		
		for (i in 0...foregrounds.length) {
			g.transformation = Matrix3.translation(Math.round(-screenOffsetX * foregroundSpeeds[i]), Math.round(-screenOffsetY * foregroundSpeeds[i]));
			//painter.translate(Math.round(-screenOffsetX * foregroundSpeeds[i]), Math.round(-screenOffsetY * foregroundSpeeds[i]));
			foregrounds[i].render(g, Std.int(screenOffsetX * foregroundSpeeds[i]), Std.int(screenOffsetY * foregroundSpeeds[i]), Game.the.width, Game.the.height);
		}
	}
	
	public function getWidth() : Float {
		if (collisionLayer != null) return collisionLayer.getMap().getWidth() * collisionLayer.getMap().getTileset().TILE_WIDTH;
		else return 0;
	}
	
	public function getHeight() : Float {
		if (collisionLayer != null) return collisionLayer.getMap().getHeight() * collisionLayer.getMap().getTileset().TILE_HEIGHT;
		else return 0;
	}
	
	public function getHeroesBelowPoint(px : Int, py : Int) : Array<Sprite> {
		var heroes = new Array();
		var count = collisionLayer.countHeroes();
		for (i in 1...count+1) {
			var hero = collisionLayer.getHero(count-i);
			if (hero.x < px && px < hero.x + hero.width && hero.y < py && py < hero.y + hero.height) {
				heroes.push(hero);
			}
		}
		ArraySort.sort(heroes, function(h1 : Sprite, h2 : Sprite) : Int { if (h1.z == h2.z) return 0; else if (h1.z < h2.z) return 1; else return -1; } );
		return heroes;
	}
	
	public function getSpritesBelowPoint(px : Int, py : Int) : Array<Sprite> {
		var sprites = new Array();
		for (i in 0...this.sprites.length) {
			var sprite = this.sprites[i];
			if (sprite.x + sprite.width < px)
				continue;
			if (sprite.x > px)
				break;
			var rect = sprite.collisionRect();
			if (rect.x < px && px < rect.x + rect.width && rect.y < py && py < rect.y + rect.height) {
				sprites.push(sprite);
			}
		}
		ArraySort.sort(sprites, function(h1 : Sprite, h2 : Sprite) : Int { if (h1.z == h2.z) return 0; else if (h1.z < h2.z) return 1; else return -1; } );
		return sprites;
	}
}