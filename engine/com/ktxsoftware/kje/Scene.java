package com.ktxsoftware.kje;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.ListIterator;

public class Scene {
	private static Scene instance;
	
	private Tilemap colissionMap;
	private List<Tilemap> backgrounds = new ArrayList<Tilemap>();
	private List<Tilemap> foregrounds = new ArrayList<Tilemap>();
	private List<Double> backgroundSpeeds = new ArrayList<Double>();
	private List<Double> foregroundSpeeds = new ArrayList<Double>();
	private List<Sprite> lastUpdatedSprites = new ArrayList<Sprite>();
	private List<Sprite> updatedSprites = new ArrayList<Sprite>();
	
	private LinkedList<Sprite> heroes, sprites, enemies;
	
	private Color backgroundColor = new Color(0, 0, 0);
	
	public int camx, camy;
	
	public static Scene getInstance() {
		return instance;
	}
	
	public Scene() {
		instance = this;
		sprites = new LinkedList<Sprite>();
		heroes = new LinkedList<Sprite>();
		enemies = new LinkedList<Sprite>();
	}
	
	public void clear() {
		colissionMap = null;
		clearTilemaps();
		heroes.clear();
		enemies.clear();
		sprites.clear();
	}
	
	public void clearTilemaps() {
		backgrounds.clear();
		foregrounds.clear();
		backgroundSpeeds.clear();
		foregroundSpeeds.clear();
	}
	
	public void setBackgroundColor(Color color) {
		backgroundColor = color;
	}
	
	public LinkedList<Sprite> getEnemies() {
		return enemies;
	}
	
	public void addBackgroundTilemap(Tilemap tilemap, double speed) {
		backgrounds.add(tilemap);
		backgroundSpeeds.add(speed);
	}
	
	public void addForegroundTilemap(Tilemap tilemap, double speed) {
		foregrounds.add(tilemap);
		foregroundSpeeds.add(speed);
	}
	
	public void setColissionMap(Tilemap tilemap) {
		colissionMap = tilemap;
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
	
	public void removeHero(Sprite sprite) {
		heroes.remove(sprite);
		sprites.remove(sprite);
	}
	
	private int adjustCamX() {
		if (colissionMap != null) {
			int realcamx = Math.min(Math.max(0, camx - Game.getInstance().getWidth() / 2), colissionMap.getWidth() * colissionMap.getTileset().TILE_WIDTH - Game.getInstance().getWidth());
			if (getWidth() < Game.getInstance().getWidth()) realcamx = 0;
			return realcamx;
		}
		else return camx;
	}
	
	private void bubbleSort(LinkedList<Sprite> sprites) {
		boolean changed = true;
		while (changed) {
			changed = false;
			ListIterator<Sprite> it = sprites.listIterator();
			Sprite last, current;
			if (it.hasNext()) current = it.next();
			else return;
			while (it.hasNext()) {
				last = current;
				current = it.next();
				if (last.x > current.x) {
					it.previous();
					it.previous();
					it.remove();
					it.next();
					it.add(last);
					changed = true;
				}
			}
		}
	}
	
	public void update() {
		int camx = adjustCamX();
		bubbleSort(sprites);
		int i = 0;
		for (; i < sprites.size(); ++i) {
			if (sprites.get(i).x + sprites.get(i).width > camx) break;
		}
		for (; i < sprites.size(); ++i) {
			Sprite sprite = sprites.get(i);
			if (sprite.x > camx + Game.getInstance().getWidth()) break;
			sprite.update();
			move(sprite);
			updatedSprites.add(sprite);
		}
		for (Sprite sprite : lastUpdatedSprites)
		{
			if (!updatedSprites.contains(sprite)) sprite.outOfView();
		}
		lastUpdatedSprites.clear();
		lastUpdatedSprites.addAll(updatedSprites);
		updatedSprites.clear();
		
		bubbleSort(heroes);
		bubbleSort(enemies);
		i = 0;
		
		for (; i < enemies.size(); ++i) {
			if (enemies.get(i).x + enemies.get(i).width > camx) break;
		}
		for (; i < enemies.size(); ++i) {
			if (enemies.get(i).x > camx + Game.getInstance().getWidth()) break;
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
			
			if (colissionMap != null) {
				if (sprite.speedx > 0) { if (colissionMap.collideright(sprite)) sprite.hit(Direction.LEFT); }
				else if (sprite.speedx < 0) { if (colissionMap.collideleft(sprite)) sprite.hit(Direction.RIGHT); }
				sprite.y += sprite.speedy;
				if (sprite.speedy > 0) { if (colissionMap.collidedown(sprite)) sprite.hit(Direction.UP); }
				else if (sprite.speedy < 0) { if (colissionMap.collideup(sprite)) sprite.hit(Direction.DOWN); }
			}
		}
		else {
			sprite.x += sprite.speedx;
			sprite.y += sprite.speedy;
		}
	}
	
	public void render(Painter painter) {
		painter.translate(0, 0);
		painter.setColor(backgroundColor.r, backgroundColor.g, backgroundColor.b);
		painter.fillRect(0, 0, Game.getInstance().getWidth(), Game.getInstance().getHeight());
		
		int camx = adjustCamX();
		
		for (int i = 0; i < backgrounds.size(); ++i) {
			painter.translate(-camx * backgroundSpeeds.get(i), camy * backgroundSpeeds.get(i));
			backgrounds.get(i).render(painter, (int)(camx * backgroundSpeeds.get(i)), 0, Game.getInstance().getWidth(), Game.getInstance().getHeight());
		}
		
		painter.translate(-camx, camy);
		
		for (int z = 0; z < 10; ++z) {
			int i = 0;
			for (; i < sprites.size(); ++i) if (sprites.get(i).x + sprites.get(i).width > camx) break;
			for (; i < sprites.size(); ++i) {
				if (sprites.get(i).x > camx + Game.getInstance().getWidth()) break;
				if (i < sprites.size() && sprites.get(i).z == z) sprites.get(i).render(painter);
			}
		}
		
		for (int i = 0; i < foregrounds.size(); ++i) {
			painter.translate(-camx * foregroundSpeeds.get(i), camy * foregroundSpeeds.get(i));
			foregrounds.get(i).render(painter, (int)(camx * foregroundSpeeds.get(i)), 0, Game.getInstance().getWidth(), Game.getInstance().getHeight());
		}
	}
	
	public double getWidth() {
		if (colissionMap != null) return colissionMap.getWidth() * colissionMap.getTileset().TILE_WIDTH;
		else return 0;
	}
}