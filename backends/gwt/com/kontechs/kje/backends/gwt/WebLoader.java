package com.kontechs.kje.backends.gwt;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.kontechs.kje.Loader;
import com.kontechs.kje.Music;
import com.kontechs.kje.Sound;
import com.kontechs.kje.TileProperty;

public class WebLoader extends Loader {
	private static LevelServiceAsync service;
	
	private static void loadingFinished() {
		Timer timer = new AnimationTimer();
		timer.scheduleRepeating(1000 / 30);
	}
	
	public WebLoader() {
		service = GWT.create(LevelService.class);
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
	public void loadHighscore() {
		
	}
	
	class MapLoader implements AsyncCallback<int[][]> {
		private String name;
		
		public MapLoader(String name) {
			this.name = name;
		}
		
		@Override
		public void onFailure(Throwable caught) {
			System.err.println("Failed loading level");
		}

		@Override
		public void onSuccess(int[][] result) {
			maps.put(name, result);
			--loadcount;
			if (loadcount <= 0) loadingFinished();
		}	
	}
	
	class TilesetLoader implements AsyncCallback<TileProperty[]> {
		private String name;
		
		public TilesetLoader(String name) {
			this.name = name;
		}
		
		@Override
		public void onFailure(Throwable caught) {
			System.err.println("Failed loading level");
		}

		@Override
		public void onSuccess(TileProperty[] result) {
			tilesets.put(name, result);
			--loadcount;
			if (loadcount <= 0) loadingFinished();
		}	
	}
	
	@Override
	protected void loadMap(String name) {
		service.getLevel(name, new MapLoader(name));
	}
	
	@Override
	protected void loadTileset(String name) {
		service.getTileset(name, new TilesetLoader(name));
	}
}