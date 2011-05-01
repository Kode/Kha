package com.kontechs.kje;

import java.io.Serializable;

//TODO: Generalize
public class TileProperty implements Serializable {
	private static final long serialVersionUID = 1L;
	public static final int SEASONMODE_SUMMERONLY = 0;
	public static final int SEASONMODE_WINTERONLY = 1;
	public static final int SEASONMODE_BOTH = 2;
	
	private boolean isEnemy;
	private String enemyTyp;
	private boolean collides;
	private int seasonMode;
	private int linkedTile;
	
	public TileProperty() {
		this.isEnemy = false;
		this.enemyTyp = "";
		this.collides = false;
		this.seasonMode = SEASONMODE_SUMMERONLY;
		this.linkedTile = 0;
	}
	
	public boolean isEnemy() {
		return isEnemy;
	}
	public void setEnemy(boolean isEnemy) {
		this.isEnemy = isEnemy;
	}
	public String getEnemyTyp() {
		return enemyTyp;
	}
	public void setEnemyTyp(String enemyTyp) {
		this.enemyTyp = enemyTyp;
	}
	public boolean isCollides() {
		return collides;
	}
	public void setCollides(boolean collides) {
		this.collides = collides;
	}
	
	//TODO: Generalize
	public int getSeasonMode() {
		return seasonMode;
	}
	public void setSeasonMode(int seasonMode) {
		this.seasonMode = seasonMode;
	}
	
	public int getLinkedTile() {
		return linkedTile;
	}
	public void setLinkedTile(int linkedTile) {
		this.linkedTile = linkedTile;
	}
	
}
