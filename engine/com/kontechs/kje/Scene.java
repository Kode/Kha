package com.kontechs.kje;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

class SpriteXComparator implements Comparator<Sprite> {
	@Override
	public int compare(Sprite o1, Sprite o2) {
		if (o1.x < o2.x) return -1;
		else if (o1.x > o2.x) return 1;
		return 0;
	}
}

public class Scene {
	private static Scene instance;
	private Tilemap tilemap;
	private ArrayList<Sprite> sprites, heroes, enemies;
	private SpriteXComparator comparator = new SpriteXComparator();
	
	public static Scene getInstance() {
		return instance;
	}
	
	public Scene() {
		instance = this;
		sprites = new ArrayList<Sprite>();
		heroes = new ArrayList<Sprite>();
		enemies = new ArrayList<Sprite>();
	}
	
	public void setTilemap(Tilemap tilemap) {
		this.tilemap = tilemap;
	}
	
	public void addHero(Sprite sprite) {
		heroes.add(sprite);
		sprites.add(sprite);
	}
	
	public void addEnemy(Sprite sprite) {
		enemies.add(sprite);
		sprites.add(sprite);
	}
	
	public void removeEnemy(Sprite sprite) {
		enemies.remove(sprite);
		sprites.remove(sprite);
	}
	
	public void update() {
		Collections.sort(sprites, comparator);
		int i = 0;
		for (; i < sprites.size(); ++i) {
			if (sprites.get(i).x + sprites.get(i).width> camx - System.getInstance().getXRes() / 2) break;
		}
		for (; i < sprites.size(); ++i) {
			if (sprites.get(i).x > camx + System.getInstance().getXRes() / 2) break;
			sprites.get(i).update();
			move(sprites.get(i));
		}
		Collections.sort(heroes, comparator);
		Collections.sort(enemies, comparator);
		i = 0;
		for (; i < enemies.size(); ++i) {
			if (enemies.get(i).x > camx - System.getInstance().getXRes() / 2) break;
		}
		for (; i < enemies.size(); ++i) {
			if (enemies.get(i).x > camx + System.getInstance().getXRes() / 2) break;
			Rectangle rect1 = enemies.get(i).collisionRect();
			for (int i2 = 0; i2 < heroes.size(); ++i2) {
				Rectangle rect2 = heroes.get(i2).collisionRect();
				if (rect1.collision(rect2)) {
					heroes.get(i2).hit(enemies.get(i));
					enemies.get(i).hit(heroes.get(i2));
				}
			}
		}
	}
	
	private void move(Sprite sprite) {
		sprite.speedx += sprite.accx;
		sprite.speedy += sprite.accy;
		if (sprite.collides) {
			if (sprite.speedy > sprite.maxspeedy) sprite.speedy = sprite.maxspeedy;
			sprite.x += sprite.speedx;
			if (sprite.speedx > 0) { if (tilemap.collideright(sprite)) sprite.hit(Direction.LEFT); }
			else if (sprite.speedx < 0) { if (tilemap.collideleft(sprite)) sprite.hit(Direction.RIGHT); }
			sprite.y += sprite.speedy;
			if (sprite.speedy > 0) { if (tilemap.collidedown(sprite)) sprite.hit(Direction.UP); }
			else if (sprite.speedy < 0) { if (tilemap.collideup(sprite)) sprite.hit(Direction.DOWN); }
		}
		else {
			sprite.x += sprite.speedx;
			sprite.y += sprite.speedy;
		}
	}
	
	public void render(Painter painter) {
		painter.translate(0, 0);
		painter.setColor(255, 255, 255);
		painter.fillRect(0, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
		
		int realcamx = Math.min(Math.max(0, camx - System.getInstance().getXRes() / 2), tilemap.getWidth() * Tileset.TILE_WIDTH - System.getInstance().getXRes());
		
		painter.translate(-realcamx, 25);
		tilemap.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
		
		int i = 0;
		for (; i < sprites.size(); ++i) {
			if (sprites.get(i).x  + sprites.get(i).width > realcamx) break;
		}
		for (; i < sprites.size(); ++i) {
			if (sprites.get(i).x > realcamx + System.getInstance().getXRes()) break;
			sprites.get(i).render(painter);
		}
	}
	
	public int camx, camy;
}