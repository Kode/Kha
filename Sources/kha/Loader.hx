package kha;

class Loader {
	static var instance : Loader;
	var blobs : Hash<Blob>;
	var images : Hash<Image>;
	var sounds : Hash<Sound>;
	var musics : Hash<Music>;
	var videos : Hash<Video>;
	var xmls : Hash<Xml>;
	var loadcount : Int;
	var numberOfFiles : Int;
	
	public function new() {
		blobs = new Hash<Blob>();
		images = new Hash<Image>();
		sounds = new Hash<Sound>();
		musics = new Hash<Music>();
		videos = new Hash<Video>();
		xmls = new Hash<Xml>();
		loadcount = 100;
		numberOfFiles = 100;
	}
	
	public static function init(loader : Loader) {
		instance = loader;
	}
	
	public static function getInstance() : Loader {
		return instance;
	}
	
	public function getLoadPercentage() : Int {
		return Std.int((loadcount - numberOfFiles) / loadcount * 100);
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
	
	public function getVideo(name : String) : Video {
		return videos.get(name);
	}
	
	public function getXml(name : String) : Xml {
		return xmls.get(name);
	}
	
	public function getAvailableBlobs() : Iterator<String> {
		return blobs.keys();
	}
	
	public function getAvailableImages() : Iterator<String> {
		return images.keys();
	}
	
	public function getAvailableMusic() : Iterator<String> {
		return musics.keys();
	}
	
	public function getAvailableSounds() : Iterator<String> {
		return sounds.keys();
	}
	
	public function getAvailableVideos() : Iterator<String> {
		return videos.keys();
	}
	
	public function getAvailableXmls() : Iterator<String> {
		return xmls.keys();
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
					if (!images.exists(dataNode.firstChild().nodeValue)) loadImage(dataNode.firstChild().nodeValue);
				case "xml":
					if (!xmls.exists(dataNode.firstChild().nodeValue)) loadXml(dataNode.firstChild().nodeValue);
				case "music":
					if (!musics.exists(dataNode.firstChild().nodeValue)) loadMusic(dataNode.firstChild().nodeValue);
				case "sound":
					if (!sounds.exists(dataNode.firstChild().nodeValue)) loadSound(dataNode.firstChild().nodeValue);
				case "video":
					if (!videos.exists(dataNode.firstChild().nodeValue)) loadVideo(dataNode.firstChild().nodeValue);
				case "blob":
					if (!blobs.exists(dataNode.firstChild().nodeValue)) loadBlob(dataNode.firstChild().nodeValue);
			}
		}
	}
	
	function loadStarted(numberOfFiles : Int) {
		this.loadcount = numberOfFiles;
		this.numberOfFiles = numberOfFiles;
	}
	
	private function loadImage(filename : String) { }
	private function loadBlob(filename : String) { }
	private function loadSound(filename : String) { }
	private function loadMusic(filename : String) { }
	private function loadVideo(filename : String) { }
	private function loadXml(filename : String) { }
	
	public function loadFont(name : String, style : FontStyle, size : Int) : Font { return null; }
	
	public function loadURL(url : String) : Void { }
	
	public function setNormalCursor() { }
	public function setHandCursor() { }
	public function setCursorBusy(busy : Bool) { }
}