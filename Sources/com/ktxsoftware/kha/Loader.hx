package com.ktxsoftware.kha;

class Loader {
	static var instance : Loader;
	var blobs : Hash<Blob>;
	var images : Hash<Image>;
	var sounds : Hash<Sound>;
	var musics : Hash<Music>;
	var xmls : Hash<Xml>;
	var loadcount : Int;
	var numberOfFiles : Int;
	
	public function new() {
		blobs = new Hash<Blob>();
		images = new Hash<Image>();
		sounds = new Hash<Sound>();
		musics = new Hash<Music>();
		xmls = new Hash<Xml>();
		loadcount = 0;
		numberOfFiles = 100;
	}
	
	public static function init(loader : Loader) {
		instance = loader;
	}
	
	public static function getInstance() : Loader {
		return instance;
	}
	
	public function getLoadPercentage() : Int {
		return Std.int(numberOfFiles / loadcount * 100);
	}
	
	public function getBlob(name : String) : Blob {
		return blobs.get(name);
	}
	
	public function getImage(name : String) : Image {
		if (!images.exists(name)) {
			trace("Could not find image " + name + ".");
		}
		return images.get(name);
	}
	
	public function getMusic(name : String) : Music {
		return musics.get(name);
	}
	
	public function getSound(name : String) : Sound {
		return sounds.get(name);
	}
	
	public function getXml(name : String) : Xml {
		return xmls.get(name);
	}
	
	public function load() {
		loadDataDefinition();
	}
	
	//override for asynchronous loading
	public function loadDataDefinition() {
		loadXml("data.xml");
		loadFiles();
	}
	
	private function loadFiles() {
		var node : Xml = getXml("data.xml");
		var size : Int = 0;
		for (element in node.elements().next().elements()) ++size;
		loadStarted(size);
		for (dataNode in node.elements().next().elements()) {
			switch (dataNode.nodeName) {
				case "image":
					loadImage(dataNode.firstChild().nodeValue);
				case "xml":
					loadXml(dataNode.firstChild().nodeValue);
				case "music":
					loadMusic(dataNode.firstChild().nodeValue);
				case "sound":
					loadSound(dataNode.firstChild().nodeValue);
				case "blob":
					loadBlob(dataNode.firstChild().nodeValue);
			}
		}
		if (Game.getInstance().hasScores()) loadHighscore();
	}
	
	function loadStarted(numberOfFiles : Int) {
		this.numberOfFiles = numberOfFiles;
	}
	
	public function loadHighscore() { }
	public function saveHighscore(score : Score) { }
	
	private function loadImage(filename : String) { }
	private function loadBlob(filename : String) { }
	private function loadSound(filename : String) { }
	private function loadMusic(filename : String) { }
	private function loadXml(filename : String) { }
	
	public function loadFont(name : String, style : FontStyle, size : Int) : Font { return null; }
	
	public function setNormalCursor() { }
	public function setHandCursor() { }
}