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
	
	private Tilemap tilemap_foreground;
	private Tilemap tilemap_overlay;
	private Tilemap tilemap_background;
	private Tilemap tilemap_background2;
	private Tilemap tilemap_background3;
	
	private ArrayList<Sprite> heroes, sprites, enemies;
	
	private boolean cooliderDebugMode = false;
	
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
	
	public ArrayList<Sprite> getEnemies() {
		return enemies;
	}

	public void setTilemapForeground(Tilemap tilemapForeground) {
		this.tilemap_foreground = tilemapForeground;
	}
	
	public void setTilemapOverlay(Tilemap tilemapOverlay){
		this.tilemap_overlay = tilemapOverlay;
	}
	
	public void setTilemapBackground(Tilemap tilemapBackground){
		this.tilemap_background = tilemapBackground;
	}
	
	public void setTilemapBackground2(Tilemap tilemapBackground2){
		this.tilemap_background2 = tilemapBackground2;
	}
	
	public void setTilemapBackground3(Tilemap tilemapBackground3){
		this.tilemap_background3 = tilemapBackground3;
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
			Sprite sprite = sprites.get(i);
			if (sprite.x > camx + System.getInstance().getXRes() / 2) break;
			sprite.update();
			move(sprite);
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
			
			if (tilemap_foreground != null) {
				if (sprite.speedx > 0) { if (tilemap_foreground.collideright(sprite)) sprite.hit(Direction.LEFT); }
				else if (sprite.speedx < 0) { if (tilemap_foreground.collideleft(sprite)) sprite.hit(Direction.RIGHT); }
				sprite.y += sprite.speedy;
				if (sprite.speedy > 0) { if (tilemap_foreground.collidedown(sprite)) sprite.hit(Direction.UP); }
				else if (sprite.speedy < 0) { if (tilemap_foreground.collideup(sprite)) sprite.hit(Direction.DOWN); }
			}
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
		
		int realcamx = 0;
		if (tilemap_foreground != null) realcamx = Math.min(Math.max(0, camx - System.getInstance().getXRes() / 2), tilemap_foreground.getWidth() * Tileset.TILE_WIDTH - System.getInstance().getXRes());
		//copy value of current realcamx to be able to translate the tilemap but still draw the tilemap at the right position
		//int realcamxChange = realcamx;
		
		/*for parallax-effect change the x-value of painter.translate and tilemapBackground.render
		 * @author Robert P.
		 */
		painter.translate((int)-realcamx/4, 25);
		if (tilemap_background != null) tilemap_background.render(painter, (int)realcamx/4,0, System.getInstance().getXRes(), System.getInstance().getYRes());
		painter.translate((int)-realcamx/3, 25);
		if (tilemap_background2 != null) tilemap_background2.render(painter, (int)realcamx/3,0, System.getInstance().getXRes(), System.getInstance().getYRes());
		painter.translate((int)-realcamx/2, 25);
		if (tilemap_background3 != null) tilemap_background3.render(painter, (int)realcamx/2,0, System.getInstance().getXRes(), System.getInstance().getYRes());
		
		painter.translate(-realcamx, 25);
		
		if (tilemap_foreground != null) tilemap_foreground.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
		if (tilemap_overlay != null) tilemap_overlay.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
		
		// paints the element based on the z-order
		// 0 first ... 3 last
		for (int z_order = 0; z_order < 4; ++z_order){
			int i = 0;
			for (; i < sprites.size(); ++i) {
				if (sprites.get(i).x  + sprites.get(i).width > realcamx) break;
			}
			for (; i < sprites.size(); ++i) {
				if (sprites.get(i).x > realcamx + System.getInstance().getXRes()){
					break;
				}
				if (sprites.get(i).getZ_order() == z_order){
					sprites.get(i).render(painter);
				}
			}
		}
	}
	
	public int camx, camy;
	
	public boolean isCooliderDebugMode() {
		return cooliderDebugMode;
	}

	public void setCooliderDebugMode(boolean cooliderDebugMode) {
		this.cooliderDebugMode = cooliderDebugMode;
	}
}