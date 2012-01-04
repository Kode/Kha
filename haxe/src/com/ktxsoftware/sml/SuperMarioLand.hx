package com.ktxsoftware.sml;

import com.ktxsoftware.kje.Color;
import com.ktxsoftware.kje.Game;
import com.ktxsoftware.kje.HighscoreList;
import com.ktxsoftware.kje.KeyEvent;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Music;
import com.ktxsoftware.kje.Painter;
import com.ktxsoftware.kje.Scene;
import com.ktxsoftware.kje.Score;
import com.ktxsoftware.kje.Tilemap;

enum Mode {
	Game;
	Highscore;
	EnterHighscore;
}

class SuperMarioLand extends Game {
	static var instance : SuperMarioLand;
	var music : Music;
	var tileColissions : Array<Bool>;
	var map : Array<Array<Int>>;
	var originalmap : Array<Array<Int>>;
	var highscoreName : String;
	
	var mode : Mode;
	
	public function new() {
		super(600, 520);
		instance = this;
		highscoreName = "";
		mode = Mode.Game;
	}
	
	public static function getInstance() : SuperMarioLand {
		return instance;
	}

	public override function init() {
		tileColissions = new Array<Bool>();
		for (i in 0...140) tileColissions.push(isCollidable(i));
		originalmap = Loader.getInstance().getMap("level.map");
		map = new Array<Array<Int>>();
		for (x in 0...originalmap.length) {
			map.push(new Array<Int>());
			for (y in 0...originalmap[0].length) {
				map[x].push(0);
			}
		}
		music = Loader.getInstance().getMusic("level1");
		startGame();
	}
	
	public function startGame() {
		if (Jumpman.getInstance() == null) new Jumpman(music);
		Scene.getInstance().clear();
		Scene.getInstance().setBackgroundColor(new Color(255, 255, 255));
		var tilemap : Tilemap = new Tilemap("sml_tiles.png", 32, 32, map, tileColissions);
		Scene.getInstance().setColissionMap(tilemap);
		Scene.getInstance().addBackgroundTilemap(tilemap, 1);
		var TILE_WIDTH : Int = 32;
		var TILE_HEIGHT : Int = 32;
		for (x in 0...originalmap.length) {
			for (y in 0...originalmap[0].length) {
				switch (originalmap[x][y]) {
				case 15:
					map[x][y] = 0;
					Scene.getInstance().addEnemy(new Gumba(x * TILE_WIDTH, y * TILE_HEIGHT));
				case 16:
					map[x][y] = 0;
					Scene.getInstance().addEnemy(new Koopa(x * TILE_WIDTH, y * TILE_HEIGHT - 16));
				case 17:
					map[x][y] = 0;
					Scene.getInstance().addEnemy(new Fly(x * TILE_WIDTH - 32, y * TILE_HEIGHT));
				case 46:
					map[x][y] = 0;
					Scene.getInstance().addEnemy(new Coin(x * TILE_WIDTH, y * TILE_HEIGHT));
				case 52:
					map[x][y] = 52;
					Scene.getInstance().addEnemy(new Exit(x * TILE_WIDTH, y * TILE_HEIGHT));
				case 56:
					map[x][y] = 1;
					Scene.getInstance().addEnemy((new BonusBlock(x * TILE_WIDTH, y * TILE_HEIGHT)));
				default:
					map[x][y] = originalmap[x][y];
				}
			}
		}
		music.start();
		Jumpman.getInstance().reset();
		Scene.getInstance().addHero(Jumpman.getInstance());
	}
	
	public function showHighscore() {
		Scene.getInstance().clear();
		mode = Mode.EnterHighscore;
		music.stop();
	}
	
	private static function isCollidable(tilenumber : Int) : Bool {
		switch (tilenumber) {
		case 1: return true;
		case 6: return true;
		case 7: return true;
		case 8: return true;
		case 26: return true;
		case 33: return true;
		case 39: return true;
		case 48: return true;
		case 49: return true;
		case 50: return true;
		case 53: return true;
		case 56: return true;
		case 60: return true;
		case 61: return true;
		case 62: return true;
		case 63: return true;
		case 64: return true;
		case 65: return true;
		case 67: return true;
		case 68: return true;
		case 70: return true;
		case 74: return true;
		case 75: return true;
		case 76: return true;
		case 77: return true;
		case 84: return true;
		case 86: return true;
		case 87: return true;
		default:
			return false;
		}
	}
	
	public override function update() {
		super.update();
		music.update();
		Scene.getInstance().camx = Std.int(Jumpman.getInstance().x) + Std.int(Jumpman.getInstance().width / 2);
	}
	
	public override function render(painter : Painter) {
		switch (mode) {
		case Highscore:
			painter.setColor(255, 255, 255);
			painter.fillRect(0, 0, getWidth(), getHeight());
			painter.setColor(0, 0, 0);
			var i : Int = 0;
			while (i < 10 && i < HighscoreList.getInstance().getScores().length) {
				var score : Score = HighscoreList.getInstance().getScores()[i];
				painter.drawString(Std.string(i + 1) + ": " + score.getName(), 100, i * 30 + 100);
				painter.drawString(" -           " + Std.string(score.getScore()), 200, i * 30 + 100);
				++i;
			}
			//break;
		case EnterHighscore:
			painter.setColor(255, 255, 255);
			painter.fillRect(0, 0, getWidth(), getHeight());
			painter.setColor(0, 0, 0);
			painter.drawString("Enter your name", getWidth() / 2 - 100, 200);
			painter.drawString(highscoreName, getWidth() / 2 - 50, 250);
			//break;
		case Game:
			super.render(painter);
			painter.translate(0, 0);
			painter.setColor(0, 0, 0);
			painter.drawString("Score: " + Std.string(Jumpman.getInstance().getScore()), 20, 25);
			painter.drawString("Round: " + Std.string(Jumpman.getInstance().getRound()), getWidth() - 100, 25);
			//break;
		}
	}

	public override function key(event : KeyEvent) {
		switch (mode) {
		case Game:
			switch (event.key) {
			case UP:
				if (event.down) Jumpman.getInstance().setUp();
				else Jumpman.getInstance().up = event.down;
			case LEFT:
				Jumpman.getInstance().left = event.down;
			case RIGHT:
				Jumpman.getInstance().right = event.down;
			default:
			}
		case EnterHighscore:
			if (highscoreName.length > 0) {
				switch (event.key) {
				case ENTER:
					HighscoreList.getInstance().addScore(highscoreName, Jumpman.getInstance().getScore());
					mode = Mode.Highscore;
				case BACKSPACE:
					highscoreName = highscoreName.substr(0, highscoreName.length - 1);
				default:
				}
			}
		default:
		}
	}
	
	public override function charKey(c : String) {
		if (mode == Mode.EnterHighscore) {
			if (highscoreName.length < 20) highscoreName += c;
		}
	}
}