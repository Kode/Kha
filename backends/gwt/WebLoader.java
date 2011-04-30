package de.hsharz.game.client;

import com.google.gwt.user.client.Timer;

import de.hsharz.game.engine.Loader;
import de.hsharz.game.engine.Music;
import de.hsharz.game.engine.Sound;

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
	public de.hsharz.game.engine.Image loadImage(String filename) {
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
	public int[][] loadLevel() {
		return level;
	}
}