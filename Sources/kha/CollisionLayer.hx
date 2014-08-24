package kha;
import kha.math.Vector2;

class CollisionLayer {
	private var map: Tilemap;
	private var heroes     : Array<Sprite>;
	private var enemies    : Array<Sprite>;
	private var projectiles: Array<Sprite>;
	private var others     : Array<Sprite>;
	
	public function new(map: Tilemap) {
		this.map = map;
		heroes      = new Array<Sprite>();
		enemies     = new Array<Sprite>();
		projectiles = new Array<Sprite>();
		others      = new Array<Sprite>();
	}
	
	public function getMap(): Tilemap {
		return map;
	}
	
	public function addHero(sprite: Sprite): Void {
		heroes.push(sprite);
	}
	
	public function addEnemy(sprite: Sprite): Void {
		enemies.push(sprite);
	}
	
	public function addProjectile(sprite: Sprite): Void {
		projectiles.push(sprite);
	}
	
	public function addOther(sprite: Sprite): Void {
		others.push(sprite);
	}
	
	public function removeHero(sprite: Sprite): Void {
		heroes.remove(sprite);
	}
	
	public function removeEnemy(sprite: Sprite): Void {
		enemies.remove(sprite);
	}
		
	public function removeProjectile(sprite: Sprite): Void {
		projectiles.remove(sprite);
	}
	
	public function removeOther(sprite: Sprite): Void {
		others.remove(sprite);
	}
	
	public function getHero(index: Int): Sprite {
		return heroes[index];
	}
	
	public function getEnemy(index: Int): Sprite {
		return enemies[index];
	}
	
	public function getProjectile(index: Int): Sprite {
		return projectiles[index];
	}
	
	public function getOther(index: Int): Sprite {
		return others[index];
	}
	
	public function countHeroes(): Int {
		return heroes.length;
	}
	
	public function countEnemies(): Int {
		return enemies.length;
	}

	public function countProjectiles(): Int {
		return projectiles.length;
	}
	
	public function countOthers(): Int {
		return others.length;
	}
	
	private function sort(sprites: Array<Sprite>): Void {
		if (sprites.length == 0) return;
		sprites.sort(function(arg0: Sprite, arg1: Sprite) {
			if (arg0.x < arg1.x) return -1;
			else if (arg0.x == arg1.x) return 0;
			else return 1;
		});
	}
	
	private function sortAllSprites(): Void {
		sort(heroes);
		sort(enemies);
		sort(projectiles);
		sort(others);
	}
	
	public function collidesPoint(point: Vector2): Bool {
		return map.collidesPoint(point);
	}

	public function collidesSprite(sprite: Sprite): Bool {
		return map.collides(sprite);
	}
	
	//Bresenhahm
	private function line(xstart: Float, ystart: Float, xend: Float, yend: Float, sprite: Sprite): Void {
		var x0 = Math.round(xstart);
		var y0 = Math.round(ystart);
		var x1 = Math.round(xend);
		var y1 = Math.round(yend);
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
				if (map.collides(sprite)) {
					sprite.y -= 1;
					if (!map.collides(sprite)) {
						continue;
					}
					else {
						sprite.y -= 1;
						if (!map.collides(sprite)) {
							continue;
						}
						else {
							sprite.y -= 1;
							if (!map.collides(sprite)) {
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
						if (map.collides(sprite)) {
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
				if (map.collides(sprite)) {
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
						if (map.collides(sprite)) {
							sprite.y -= 1;
							if (!map.collides(sprite)) {
								continue;
							}
							else {
								sprite.y -= 1;
								if (!map.collides(sprite)) {
									continue;
								}
								else {
									sprite.y -= 1;
									if (!map.collides(sprite)) {
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
	
	private function moveSprite(sprite: Sprite): Void {
		if (sprite.collides && map.collides(sprite)) {
			sprite.y = Math.ffloor(sprite.y);
			while (map.collides(sprite) && sprite.y > - sprite.height) {
				sprite.y -= 1;
			}
		}
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
			if (map.collides(sprite)) {
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
	
	private function moveSprites(sprites: Array<Sprite>, xleft: Float, xright: Float): Void {
		/*var i: Int = 0;
		while (i < sprites.length) {
			if (sprites[i].x + sprites[i].width > xleft) break;
			++i;
		}
		while (i < sprites.length) {
			var sprite: Sprite = sprites[i];
			if (sprite.x > xright) break;
			moveSprite(sprite);
			++i;
		}*/
		for (sprite in sprites) moveSprite(sprite);
	}
	
	private function moveAllSprites(xleft: Float, xright: Float): Void {
		moveSprites(heroes, xleft, xright);
		moveSprites(enemies, xleft, xright);
		moveSprites(projectiles, xleft, xright);
		moveSprites(others, xleft, xright);
	}
	
	public function advance(xleft: Float, xright: Float): Void {
		sortAllSprites();
		moveAllSprites(xleft, xright);
		
		/*var i: Int = 0;
		while (i < enemies.length) {
			if (enemies[i].x + enemies[i].width > xleft) break;
			++i;
		}
		while (i < enemies.length) {
			var enemy = enemies[i];
			if (enemy.x > xright) break;*/
		for (enemy in enemies) {
			var rect: Rectangle = enemy.collisionRect();
			for (hero in heroes) {
				if (rect.collision(hero.collisionRect())) {
					hero.hit(enemy);
					enemy.hit(hero);
				}
			}
			for (projectile in projectiles) {
				if (rect.collision(projectile.collisionRect())) {
					projectile.hit(enemy);
					enemy.hit(projectile);
				}
			}
			/* ++i; */
		}
		
		/*i = 0;
		while (i < projectiles.length) {
			if (projectiles[i].x + projectiles[i].width > xleft) break;
			++i;
		}
		while (i < projectiles.length) {
			var projectile = projectiles[i];
			if (projectile.x > xright) break;*/
		for (projectile in projectiles) {
			var rect: Rectangle = projectile.collisionRect();
			for (hero in heroes) {
				if (rect.collision(hero.collisionRect())) {
					hero.hit(projectile);
					projectile.hit(hero);
				}
			}
			/*++i;*/
		}
		
		for (other in others) {
			var rect: Rectangle = other.collisionRect();
			for (hero in heroes) {
				if (rect.collision(hero.collisionRect())) {
					hero.hit(other);
					other.hit(hero);
				}
			}
			for (enemy in enemies) {
				if (rect.collision(enemy.collisionRect())) {
					enemy.hit(other);
					other.hit(enemy);
				}
			}
			for (projectile in projectiles) {
				if (rect.collision(projectile.collisionRect())) {
					projectile.hit(other);
					other.hit(projectile);
				}
			}
			for (other2 in others) {
				if (other != other2) {
					if (rect.collision(other2.collisionRect())) {
						other2.hit(other);
						other.hit(other2);
					}
				}
			}
		}
	}
	
	public function cleanSprites(): Void {
		var found = true;
		while (found) {
			found = false;
			for (sprite in heroes) {
				if (sprite.removed) {
					heroes.remove(sprite);
					found = true;
				}
			}
		}
		found = true;
		while (found) {
			found = false;
			for (sprite in enemies) {
				if (sprite.removed) {
					enemies.remove(sprite);
					found = true;
				}
			}
		}
		found = true;
		while (found) {
			found = false;
			for (sprite in projectiles) {
				if (sprite.removed) {
					projectiles.remove(sprite);
					found = true;
				}
			}
		}
	}
}