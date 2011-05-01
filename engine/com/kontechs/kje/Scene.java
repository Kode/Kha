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
	
	//TODO: Generalize
	private Tilemap tilemap_foreground_summer;
	private Tilemap tilemap_overlay_summer;
	private Tilemap tilemap_background_summer;
	private Tilemap tilemap_background2_summer;
	private Tilemap tilemap_background3_summer;
	private Tilemap tilemap_foreground_winter;
	private Tilemap tilemap_overlay_winter;
	private Tilemap tilemap_background_winter;
	private Tilemap tilemap_background2_winter;
	private Tilemap tilemap_background3_winter;
	
	private ArrayList<Sprite> heroes, sprites, enemies;
	
	//TODO: Check
	private int mapstranslater=0;
	private int endmapTranslater=0;
	
	//TODO: Generalize
	private String season="summer";
	private boolean seasonchange= false;
	
	private boolean cooliderDebugMode = false;
	private TileProperty[] tilesProperties;
	
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
	
	//TODO: Check
	/**
	 * 
	 * @author peter
	 * @return ArrayList<Sprite>
	 */
	public ArrayList<Sprite> getEnemies() {
		return enemies;
	}

	public void changeSeason(){
		if(this.season=="winter"){
			this.season="summer";
			this.seasonchange=true;
			
		}
		else{
			this.season="winter";
			this.seasonchange=true;
		}
	}
	
	//TODO: Generalize
	public void setTilemapForeground(Tilemap tilemapForeground_summer,Tilemap tilemapForeground_winter) {
		this.tilemap_foreground_summer = tilemapForeground_summer;
		this.tilemap_foreground_winter = tilemapForeground_winter;
	}
	public void setTilemapOverlay(Tilemap tilemapOverlay_summer,Tilemap tilemapOverlay_winter){
		this.tilemap_overlay_summer = tilemapOverlay_summer;
		this.tilemap_overlay_winter = tilemapOverlay_winter;
	}
	public void setTilemapBackground(Tilemap tilemapBackground_summer,Tilemap tilemapBackground_winter){
		this.tilemap_background_summer = tilemapBackground_summer;
		this.tilemap_background_winter = tilemapBackground_winter;
	}	
	public void setTilemapBackground2(Tilemap tilemapBackground2_summer,Tilemap tilemapBackground2_winter){
		this.tilemap_background2_summer = tilemapBackground2_summer;
		this.tilemap_background2_winter = tilemapBackground2_winter;
	}	
	public void setTilemapBackground3(Tilemap tilemapBackground3_summer,Tilemap tilemapBackground3_winter){
		this.tilemap_background3_summer = tilemapBackground3_summer;
		this.tilemap_background3_winter = tilemapBackground3_winter;
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
				
				//TODO: Check and generalize
				//if the enemy is a burstingBranch -> sprite only collides when the hero is on top of the burstingbranch-sprite
				//@author Robert Pabst
				if(enemies.get(i).name=="BurstingBranch" || enemies.get(i).name =="Water"){
					if (rect1.collisionTopOnly(rect2)) {
						if (heroes.get(i2).speedy > 0) { 
							if (enemies.get(i).collidetop(heroes.get(i2))) {
								heroes.get(i2).hit(Direction.UP); 
								enemies.get(i).hit(heroes.get(i2));
							}
						}
					}
				}
				else if(enemies.get(i).name =="treeHole"){
					if (rect1.collision(rect2)) {
						if (heroes.get(i2).speedy < 0 && enemies.get(i).collides && heroes.get(i2).x+8<enemies.get(i).x+enemies.get(i).width && heroes.get(i2).x+40>enemies.get(i).x  ) { 
								enemies.get(i).collidedown(heroes.get(i2));
								heroes.get(i2).hit(Direction.DOWN); 
						}
						else if (heroes.get(i2).speedy > 0 && enemies.get(i).collides && heroes.get(i2).x+8<enemies.get(i).x+enemies.get(i).width && heroes.get(i2).x+40>enemies.get(i).x ) { 
								enemies.get(i).collidetop(heroes.get(i2));
								heroes.get(i2).hit(Direction.UP); 
						}
						enemies.get(i).hit(heroes.get(i2));
					}
				}
				//else normal collide
				else{
					if (rect1.collision(rect2)) {
						heroes.get(i2).hit(enemies.get(i));
						enemies.get(i).hit(heroes.get(i2));
					}
				}
			}
		}
	}
	
	//TODO: Check and generalize
	private void move(Sprite sprite) {
		sprite.speedx += sprite.accx;
		sprite.speedy += sprite.accy;
		if (sprite.collides) {
			if (sprite.speedy > sprite.maxspeedy) sprite.speedy = sprite.maxspeedy;
			sprite.x += sprite.speedx;
			// other collide property in winter mode possible ... so test actual season map and not only summer map
			if(Scene.getInstance().season.equals("summer")){
				if (sprite.speedx > 0) { if (tilemap_foreground_summer.collideright(sprite)) sprite.hit(Direction.LEFT); }
				else if (sprite.speedx < 0) { if (tilemap_foreground_summer.collideleft(sprite)) sprite.hit(Direction.RIGHT); }
				sprite.y += sprite.speedy;
				if (sprite.speedy > 0) { if (tilemap_foreground_summer.collidedown(sprite)) sprite.hit(Direction.UP); }
				else if (sprite.speedy < 0) { if (tilemap_foreground_summer.collideup(sprite)) sprite.hit(Direction.DOWN); }
			}else{
				if (sprite.speedx > 0) { if (tilemap_foreground_winter.collideright(sprite)) sprite.hit(Direction.LEFT); }
				else if (sprite.speedx < 0) { if (tilemap_foreground_winter.collideleft(sprite)) sprite.hit(Direction.RIGHT); }
				sprite.y += sprite.speedy;
				if (sprite.speedy > 0) { if (tilemap_foreground_winter.collidedown(sprite)) sprite.hit(Direction.UP); }
				else if (sprite.speedy < 0) { if (tilemap_foreground_winter.collideup(sprite)) sprite.hit(Direction.DOWN); }
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
		
		int realcamx = Math.min(Math.max(0, camx - System.getInstance().getXRes() / 2), tilemap_foreground_summer.getWidth() * Tileset.TILE_WIDTH - System.getInstance().getXRes());
		//copy value of current realcamx to be able to translate the tilemap but still draw the tilemap at the right position
		int realcamxChange= realcamx;
		
		//TODO: Check and generalize
		
		// Bug-Fix ... Hole paint Problems ... beaver was up to the middle 
		// of the hole painted behind the hole (middle point / collision model
		// problems) Beaver was first painted and then the hole over the beaver
		// Now: if the beaver is the sprite element before the hole, the elements
		// are twisted, so that the beaver is painted after the hole and so over
		// the hole every time
//		int index_hole = 0;
//		int index_beaver = 0;
//		for(int n = 0;n<sprites.size();n++){
//			if(sprites.get(n).getClass().equals(Beaver.class)) index_beaver = n;
//			if(sprites.get(n).getClass().equals(WoodHole.class)) index_hole = n;
//			if(index_hole == (index_beaver + 1)){
//			Sprite temp_sprite = sprites.get(index_hole);
//			sprites.set(index_hole,sprites.get(index_beaver));
//			sprites.set(index_beaver, temp_sprite);
//				//java.lang.System.out.println("aneinander");
//				break;
//			}
//		}
		
		if (season=="winter"){
			/*for parallax-effect change the x-value of painter.translate and tilemapBackground.render
			 * @author Robert P.
			 */
			painter.translate((int)-realcamx/4, 25);
			tilemap_background_winter.render(painter, (int)realcamx/4,0, System.getInstance().getXRes(), System.getInstance().getYRes());
			painter.translate((int)-realcamx/3, 25);
			tilemap_background2_winter.render(painter, (int)realcamx/3,0, System.getInstance().getXRes(), System.getInstance().getYRes());
			painter.translate((int)-realcamx/2, 25);
			tilemap_background3_winter.render(painter, (int)realcamx/2,0, System.getInstance().getXRes(), System.getInstance().getYRes());
			
			painter.translate(-realcamx, 25);
			
			if (seasonchange){
				//increment mapstranslater to translate both maps, the startmap and endmap
				mapstranslater+=20;
				//translate the current map to the right
				realcamxChange+=mapstranslater;
				//as long as the map is displayed in the current cam-position, render the map from x-value=realcamxChange
				if(realcamxChange<realcamx+640){
					tilemap_foreground_summer.render(painter, realcamxChange, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
					tilemap_overlay_summer.render(painter, realcamxChange, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
				}
				/*as soon as the start-map has been translated by XX-Pixels to the right->
				 *start to display the end-map, which will also be translated with the same speed as the start-map 
				 */
				if(mapstranslater>20 && realcamxChange<realcamx+640){
					endmapTranslater= endmapTranslater+20;
					tilemap_foreground_winter.render(painter, realcamx, 0, endmapTranslater, System.getInstance().getYRes());
					tilemap_overlay_winter.render(painter, realcamx, 0, endmapTranslater, System.getInstance().getYRes());
				}
				//as soon as the end-map is completely displayed -> start to display the new map
				else if(mapstranslater==640){
					mapstranslater=0;
					endmapTranslater=0;
					seasonchange=false;
					tilemap_foreground_winter.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
					tilemap_overlay_winter.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
				}
			}
			else{
				tilemap_foreground_winter.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
				tilemap_overlay_winter.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
			}
			
			
			
			
		}
		//season=="summer"
		else{
			/*for parallax-effect change the x-value of painter.translate and tilemapBackground.render
			 * @author Robert P.
			 */
			painter.translate((int)-realcamx/4, 25);
			tilemap_background_summer.render(painter, (int)realcamx/4,0, System.getInstance().getXRes(), System.getInstance().getYRes());
			painter.translate((int)-realcamx/3, 25);
			tilemap_background2_summer.render(painter, (int)realcamx/3 ,0, System.getInstance().getXRes(), System.getInstance().getYRes());
			painter.translate((int)-realcamx/2, 25);
			tilemap_background3_summer.render(painter, (int)realcamx/2,0, System.getInstance().getXRes(), System.getInstance().getYRes());
			
			
			painter.translate(-realcamx, 25);
			if (seasonchange){
				//increment mapstranslater to translate both maps, the startmap and endmap
				mapstranslater+=20;
				//translate the current map to the right
				realcamxChange+=mapstranslater;
				//as long as the map is displayed in the current cam-position, render the map from x-value=realcamxChange
				if(realcamxChange<realcamx+640){
					tilemap_foreground_winter.render(painter, realcamxChange, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
					tilemap_overlay_winter.render(painter, realcamxChange, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
				}
				/*as soon as the start-map has been translated by XX-Pixels to the right->
				 *start to display the end-map, which will also be translated with the same speed as the start-map 
				 */
				if(mapstranslater>20 && realcamxChange<realcamx+640){
					endmapTranslater= endmapTranslater+20;
					tilemap_foreground_summer.render(painter, realcamx, 0, endmapTranslater, System.getInstance().getYRes());
					tilemap_overlay_summer.render(painter, realcamx, 0, endmapTranslater, System.getInstance().getYRes());
				}
				//as soon as the end-map is completely displayed -> start to display the new map
				else if(mapstranslater==640){
					mapstranslater=0;
					endmapTranslater=0;
					seasonchange=false;
					tilemap_foreground_summer.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
					tilemap_overlay_summer.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
				}
			}
			else{
				tilemap_foreground_summer.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
				tilemap_overlay_summer.render(painter, realcamx, 0, System.getInstance().getXRes(), System.getInstance().getYRes());
			}
			
			
		}
		
		// paints the element based on the z-order
		// 0 first ... 3 last
		for(int z_order = 0;z_order<4;z_order++){
			int i = 0;
			for (; i < sprites.size(); ++i) {
				if (sprites.get(i).x  + sprites.get(i).width > realcamx) break;
			}
			for (; i < sprites.size(); ++i) {
				if (sprites.get(i).x > realcamx + System.getInstance().getXRes()){
					break;
				}
				if(sprites.get(i).getZ_order() == z_order){
					sprites.get(i).render(painter);
				}
			}
		}
		
		//TODO
		//painter.drawStatusLine();
		//painter.drawExcavatorLife(100, 100);
	}
	
	public int camx, camy;

	public void setTileProperties(String tilesPropertyName) {
		this.tilesProperties = Loader.getInstance().getTileset(tilesPropertyName);
	}
	
	//TODO: Generalize
	public String getSeason() {
		return season;
	}
	
	public TileProperty[] getTilesProperties(){
		return this.tilesProperties;
	}

	public boolean isCooliderDebugMode() {
		return cooliderDebugMode;
	}

	public void setCooliderDebugMode(boolean cooliderDebugMode) {
		this.cooliderDebugMode = cooliderDebugMode;
	}
}