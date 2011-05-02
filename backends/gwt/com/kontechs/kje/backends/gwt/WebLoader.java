package com.kontechs.kje.backends.gwt;

import com.google.gwt.core.client.GWT;
import com.google.gwt.dom.client.ImageElement;
import com.google.gwt.event.dom.client.LoadEvent;
import com.google.gwt.event.dom.client.LoadHandler;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.RootPanel;
import com.kontechs.kje.Loader;
import com.kontechs.kje.TileProperty;

public class WebLoader extends Loader {
	private LevelServiceAsync service;
	private Button button;
	private int filecount;
	
	private void loadingFinished() {
		RootPanel.get().remove(button);
		Timer timer = new AnimationTimer();
		timer.scheduleRepeating(1000 / 30);
	}
	
	public WebLoader() {
		service = GWT.create(LevelService.class);
	}

	@Override
	protected void loadSound(String name) {
		sounds.put(name, new WebSound(name));
		fileLoaded();
	}

	@Override
	protected void loadMusic(String name) {
		musics.put(name, new WebMusic(name));
		fileLoaded();
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
			fileLoaded();
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
			fileLoaded();
		}	
	}
	
	class ImageLoader implements LoadHandler {
		private String name;
		private com.google.gwt.user.client.ui.Image img;
		
		public ImageLoader(String name) {
			this.name = name;
			img = new com.google.gwt.user.client.ui.Image(name + ".png");
			img.addLoadHandler(this);
			img.setVisible(false);
		    RootPanel.get().add(img); // image must be on page to fire load
		}

		@Override
		public void onLoad(LoadEvent event) {
			images.put(name, new WebImage((ImageElement) img.getElement().cast()));
			fileLoaded();
		}
	}
	
	private void fileLoaded() {
		--loadcount;
		button.setText("Loading: " + (int)((filecount - loadcount) / filecount * 100) + "%");
		if (loadcount <= 0) {
			loadingFinished();
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
	
	@Override
	protected void loadImage(String name) {
		new ImageLoader(name);
	}
	
	@Override
	protected void loadStarted() {
		filecount = loadcount;
		button = new Button("Loading: 0%");
		button.setEnabled(false);
		RootPanel.get().add(button);
	}
}