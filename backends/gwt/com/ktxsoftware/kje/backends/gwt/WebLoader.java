package com.ktxsoftware.kje.backends.gwt;

import java.util.ArrayList;

import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.LoadEvent;
import com.google.gwt.event.dom.client.LoadHandler;
import com.google.gwt.http.client.Request;
import com.google.gwt.http.client.RequestBuilder;
import com.google.gwt.http.client.RequestCallback;
import com.google.gwt.http.client.Response;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.xml.client.XMLParser;
import com.ktxsoftware.kje.Font;
import com.ktxsoftware.kje.HighscoreList;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Score;

public class WebLoader extends Loader {
	private LevelServiceAsync service;
	private Button button;
	private int filecount;
	
	private void loadingFinished() {
		RootPanel.get().remove(button);
		new AnimationTimer();
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
	
	/*class TilesetLoader implements AsyncCallback<TileProperty[]> {
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
	}*/
	
	class ImageLoader implements LoadHandler {
		private String name;
		private com.google.gwt.user.client.ui.Image img;
		
		public ImageLoader(String name) {
			this.name = name;
			img = new com.google.gwt.user.client.ui.Image(name);
			img.addLoadHandler(this);
			img.setVisible(false);
		    RootPanel.get().add(img); // image must be on page to fire load
		}

		@Override
		public void onLoad(LoadEvent event) {
			RootPanel.get().remove(img);
			images.put(name, new WebImage(name, img));
			fileLoaded();
		}
	}
	
	class XmlLoader implements RequestCallback {
		private String name;
		
		public XmlLoader(String name) {
			this.name = name;
			RequestBuilder requestBuilder = new RequestBuilder(RequestBuilder.GET, name);
			try {
				requestBuilder.sendRequest(null, this);
			}
			catch (Exception ex) {
				ex.printStackTrace();
			}
		}

		@Override
		public void onResponseReceived(Request request, Response response) {
			xmls.put(name, new WebXml(XMLParser.parse(response.getText()).getDocumentElement()));
			fileLoaded();
		}

		@Override
		public void onError(Request request, Throwable exception) {
			System.err.println("Error loading " + name + ".");
		}
	}
	
	private void fileLoaded() {
		--loadcount;
		button.setText("Loading: " + (int)((filecount - loadcount) * 100 / filecount) + "%");
		if (loadcount <= 0) {
			loadingFinished();
		}
	}
	
	@Override
	protected void loadMap(String name) {
		service.getLevel(name, new MapLoader(name));
	}
	
	/*@Override
	protected void loadTileset(String name) {
		service.getTileset(name, new TilesetLoader(name));
	}*/
	
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

	@Override
	public Font loadFont(String name, int style, int size) {
		return new WebFont(name);
	}
	
	@Override
	public void loadHighscore() {
		service.getScores(new AsyncCallback<java.util.ArrayList<Score>>() {
			@Override
			public void onFailure(Throwable caught) {
				
			}

			@Override
			public void onSuccess(ArrayList<Score> result) {
				HighscoreList.getInstance().init(result);
				fileLoaded();
			}
		});
	}

	@Override
	public void saveHighscore(Score score) {
		service.addScore(score, new AsyncCallback<Void>() {
			@Override
			public void onFailure(Throwable caught) {
				
			}

			@Override
			public void onSuccess(Void result) {
				
			}
		});
	}

	@Override
	protected void loadXml(String name) {
		new XmlLoader(name);
	}

	@Override
	public void setNormalCursor() {
		DOM.setStyleAttribute(RootPanel.get().getElement(), "cursor", "default");
	}

	@Override
	public void setHandCursor() {
		DOM.setStyleAttribute(RootPanel.get().getElement(), "cursor", "pointer");
	}
}