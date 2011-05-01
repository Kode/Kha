package com.kontechs.kje.backends.gwt;

import com.google.gwt.user.client.Timer;

import com.kontechs.kje.Loader;
import com.kontechs.kje.Music;
import com.kontechs.kje.Sound;
import com.kontechs.kje.TileProperty;

public class WebLoader extends Loader {
	private static int[][] level;
	
	public static void load() {
		/*GreetingServiceAsync service = GWT.create(GreetingService.class);
		service.getLevel(new AsyncCallback<int[][]>() {
			@Override
			public void onFailure(Throwable caught) {
				
			}

			@Override
			public void onSuccess(int[][] result) {
				level = result;
				loadingFinished();
			}
		});*/
		int levelWidth = LevelMap.levelmap[0];
		int levelHeight = LevelMap.levelmap[1];
		int index = 2;
		level = new int[levelWidth][levelHeight];
		for (int x = 0; x < levelWidth; ++x) {
			for (int y = 0; y < levelHeight; ++y) {
				level[x][y] = LevelMap.levelmap[index++];
			}
		}
		loadingFinished();
	}
	
	private static void loadingFinished() {
		Timer timer = new AnimationTimer();
		timer.scheduleRepeating(1000 / 30);
	}

	@Override
	public com.kontechs.kje.Image loadImage(String filename) {
		return new WebImage(filename);
	}

	@Override
	public Sound loadSound(String filename) {
		return new WebSound(filename);
	}

	@Override
	public Music loadMusic(String filename) {
		return new WebMusic(filename);
	}

	@Override
	public int[][] loadLevel(String lvl_name) {
		return level;
	}

	@Override
	public TileProperty[] loadTilesProperties(String tilesPropertyName) {
		TileProperty[] properties = new TileProperty[256];
		for (int i = 0; i < 256; ++i) properties[i] = new TileProperty();
		return properties;
	}

	@Override
	public void loadHighscore() {
		
	}
}