package com.ktxsoftware.kje;

import com.ktxsoftware.kje.xml.Node;

public abstract class Loader {
	private static Loader instance;
	protected java.util.Map<String, int[][]> maps = new java.util.HashMap<String, int[][]>();
	protected java.util.Map<String, Image> images = new java.util.HashMap<String, Image>();
	protected java.util.Map<String, Sound> sounds = new java.util.HashMap<String, Sound>();
	protected java.util.Map<String, Music> musics = new java.util.HashMap<String, Music>();
	protected java.util.Map<String, Node> xmls = new java.util.HashMap<String, Node>();
	protected int loadcount = 0;
	
	public static void init(Loader loader) {
		instance = loader;
	}
	
	public static Loader getInstance() {
		return instance;
	}
	
	public int[][] getMap(String name) {
		return maps.get(name);
	}
	
	public Image getImage(String name) {
		if (!images.containsKey(name)) {
			java.lang.System.err.println("Could not find image " + name + ".");
		}
		return images.get(name);
	}
	
	public Music getMusic(String name) {
		return musics.get(name);
	}
	
	public Sound getSound(String name) {
		return sounds.get(name);
	}
	
	public Node getXml(String name) {
		return xmls.get(name);
	}
	
	public void load() {
		loadXml("data.xml");
		loadStarted();		
		Node node = getXml("data.xml");
		for (Node dataNode : node.getChilds()) {
			if (dataNode.getName().equals("image")) loadImage(dataNode.getValue());
			else if (dataNode.getName().equals("xml")) loadXml(dataNode.getValue());
			else if (dataNode.getName().equals("music")) loadMusic(dataNode.getValue());
			else if (dataNode.getName().equals("sound")) loadSound(dataNode.getValue());
			else if (dataNode.getName().equals("map")) loadMap(dataNode.getValue());
		}
		loadHighscore();
	}
	
	protected void loadStarted() { }
	
	public abstract void loadHighscore();
	public abstract void saveHighscore(Score score);
	
	protected abstract void loadImage(String filename);
	protected abstract void loadMap(String name);
	protected abstract void loadSound(String filename);
	protected abstract void loadMusic(String filename);
	protected abstract void loadXml(String filename);
	
	public abstract Font loadFont(String name, int style, int size);
	
	public abstract void setNormalCursor();
	public abstract void setHandCursor();
}