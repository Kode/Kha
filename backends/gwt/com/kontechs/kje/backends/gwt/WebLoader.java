package com.kontechs.kje.backends.gwt;

import java.util.Iterator;
import java.util.Set;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.rpc.AsyncCallback;

import com.kontechs.kje.Loader;
import com.kontechs.kje.Music;
import com.kontechs.kje.Sound;
import com.kontechs.kje.TileProperty;

public class WebLoader extends Loader {
	private static LevelServiceAsync service;
	private java.util.Map<String, int[][]> maps = new java.util.HashMap<String, int[][]>();
	private java.util.Map<String, TileProperty[]> tilesets = new java.util.HashMap<String, TileProperty[]>();
	private int loadcount;
	
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
	public int[][] getMap(String name) {
		return maps.get(name);
	}

	@Override
	public TileProperty[] getTileset(String tilesPropertyName) {
		return tilesets.get(tilesPropertyName);
	}

	@Override
	public void loadHighscore() {
		
	}
	
	@Override
	public void setTilesets(String[] names) {
		tilesets.clear();
		for (int i = 0; i < names.length; ++i) tilesets.put(names[i], null);
		loadcount += names.length;
	}

	@Override
	public void setMaps(String[] names) {
		maps.clear();
		for (int i = 0; i < names.length; ++i) maps.put(names[i], null);
		loadcount += names.length;
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
	public void load() {
		service = GWT.create(LevelService.class);
		Set<String> mapnames = maps.keySet();
		for (Iterator<String> it = mapnames.iterator(); it.hasNext(); ) {
			String name = it.next();
			service.getLevel(name, new MapLoader(name));
		}
		Set<String> tilesetnames = tilesets.keySet();
		for (Iterator<String> it = tilesetnames.iterator(); it.hasNext(); ) {
			String name = it.next();
			service.getTileset(name, new TilesetLoader(name));
		}
	}
}