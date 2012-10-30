package kha;

import haxe.Json;

class Asset {
	public function new(name: String, file: String, type: String) {
		this.name = name;
		this.file = file;
		this.type = type;
	}
	public var name: String;
	public var file: String;
	public var type: String;
}

class Room {
	public function new(id: String) {
		this.id = id;
		assets = new Array<Asset>();
		parent = null;
	}
	public var id: String;
	public var assets: Array<Asset>;
	public var parent: Room;
}

class Loader {
	var blobs : Hash<Blob>;
	var images : Hash<Image>;
	var sounds : Hash<Sound>;
	var musics : Hash<Music>;
	var videos : Hash<Video>;
	var xmls : Hash<Xml>;
	var loadcount : Int;
	var numberOfFiles : Int;
	
	var assets: Hash<Asset>;
	var rooms: Hash<Room>;
	public var isQuitable : Bool = false; // Some backends dont support quitting, for example if the game is embedded in a webpage
	
	public function new() {
		blobs = new Hash<Blob>();
		images = new Hash<Image>();
		sounds = new Hash<Sound>();
		musics = new Hash<Music>();
		videos = new Hash<Video>();
		xmls = new Hash<Xml>();
		assets = new Hash<Asset>();
		rooms = new Hash<Room>();
		enqueued = new Array<Asset>();
		loadcount = 100;
		numberOfFiles = 100;
		width = -1;
		height = -1;
	}
	
	public static var the(default, null): Loader;
	public var width(default, null): Int;
	public var height(default, null): Int;
	public var name(default, null): String;
	
	public static function init(loader: Loader) {
		the = loader;
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
	
	var enqueued: Array<Asset>;
	public var loadFinished: Void -> Void;
	
	public function enqueue(asset: Asset) {
		enqueued.push(asset);
	}
	
	public function loadFiles(call: Void -> Void) {
		loadFinished = call;
		loadStarted(enqueued.length);
		for (i in 0...enqueued.length) {
			switch (enqueued[i].type) {
				case "image":
					if (!images.exists(enqueued[i].file)) loadImage(enqueued[i].file); else loadDummyFile();
				case "xml":
					if (!xmls.exists(enqueued[i].file))   loadXml(enqueued[i].file);   else loadDummyFile();
				case "music":
					if (!musics.exists(enqueued[i].file)) loadMusic(enqueued[i].file); else loadDummyFile();
				case "sound":
					if (!sounds.exists(enqueued[i].file)) loadSound(enqueued[i].file); else loadDummyFile();
				case "video":
					if (!videos.exists(enqueued[i].file)) loadVideo(enqueued[i].file); else loadDummyFile();
				case "blob":
					if (!blobs.exists(enqueued[i].file))  loadBlob(enqueued[i].file);  else loadDummyFile();
			}
		}
		enqueued = new Array<Asset>();
	}
	
	public function loadProject(call: Void -> Void) {
		enqueue(new Asset("project.kha", "project.kha", "blob"));
		loadFiles(call);
	}
	
	function loadRoomAssets(room: Room) {
		for (i in 0...room.assets.length) {
			enqueue(room.assets[i]);
		}
		if (room.parent != null) loadRoomAssets(room.parent);
	}
	
	public function loadRoom(name: String, call: Void -> Void) {
		loadRoomAssets(rooms.get(name));
		loadFiles(call);
	}
	
	public function initProject() {
		var project = parseProject();
		name = project.game.name;
		width = project.game.width;
		height = project.game.height;
		var assets: Dynamic = project.assets;
		for (i in 0...assets.length) {
			var asset = new Asset(assets[i].name, assets[i].file, assets[i].type);
			this.assets.set(assets[i].id, asset);
		}
		
		var rooms: Dynamic = project.rooms;
		for (i in 0...rooms.length) {
			var room = new Room(rooms[i].id);
			var roomAssets: Dynamic = rooms[i].assets;
			for (i2 in 0...roomAssets.length) {
				room.assets.push(this.assets.get(roomAssets[i2]));
			}
			if (rooms[i].parent != null) {
				room.parent = new Room(rooms[i].parent);
			}
			this.rooms.set(rooms[i].name, room);
		}

		for (room in this.rooms) {
			if (room.parent != null) {
				for (room2 in this.rooms) {
					if (room2.id == room.parent.id) {
						room.parent = room2;
						break;
					}
				}
			}
		}
	}
	
	private function parseProject() : Dynamic {
		return Json.parse(getBlob("project.kha").toString());
	}
	
	function checkComplete() {
		if (numberOfFiles <= 0) {
			loadFinished();
		}
	}
	
	function loadDummyFile(): Void {
		--numberOfFiles;
		checkComplete();
	}
	
	function loadStarted(numberOfFiles: Int) {
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
	
	public function quit() : Void { }
}