package kha;

import haxe.Json;
import kha.loader.Asset;
import kha.loader.Room;

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
	
	public function getXml(name: String): Xml {
		return xmls.get(name);
	}
	
	public function getAvailableBlobs(): Iterator<String> {
		return blobs.keys();
	}
	
	public function getAvailableImages(): Iterator<String> {
		return images.keys();
	}
	
	public function getAvailableMusic(): Iterator<String> {
		return musics.keys();
	}
	
	public function getAvailableSounds(): Iterator<String> {
		return sounds.keys();
	}
	
	public function getAvailableVideos(): Iterator<String> {
		return videos.keys();
	}
	
	public function getAvailableXmls(): Iterator<String> {
		return xmls.keys();
	}
	
	var enqueued: Array<Asset>;
	public var loadFinished: Void -> Void;
	
	public function enqueue(asset: Asset) {
		enqueued.push(asset);
	}
	
	public static function containsAsset(assetName: String, assetType: String, map: Array<Asset>): Bool {
		for (asset in map) {
			if (asset.type == assetType && asset.name == assetName) return true;
		}
		return false;
	}
	
	private function removeImage(resources: Hash<Image>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeBlob(resources: Hash<Blob>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeMusic(resources: Hash<Music>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeSound(resources: Hash<Sound>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeVideo(resources: Hash<Video>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	public function loadFiles(call: Void -> Void) {
		loadFinished = call;
		loadStarted(enqueued.length);
		for (imagename in images.keys()) if (!containsAsset(imagename, "image", enqueued)) removeImage(images, imagename);
		for (xmlname   in xmls.keys())   if (!containsAsset(xmlname,   "xml",   enqueued)) xmls.remove(xmlname);
		for (musicname in musics.keys()) if (!containsAsset(musicname, "music", enqueued)) removeMusic(musics, musicname);
		for (soundname in sounds.keys()) if (!containsAsset(soundname, "sound", enqueued)) removeSound(sounds, soundname);
		for (videoname in videos.keys()) if (!containsAsset(videoname, "video", enqueued)) removeVideo(videos, videoname);
		for (blobname  in blobs.keys())  if (!containsAsset(blobname,  "blob",  enqueued)) removeBlob(blobs, blobname);
		for (i in 0...enqueued.length) {
			switch (enqueued[i].type) {
				case "image":
					if (!images.exists(enqueued[i].name)) loadImage(enqueued[i]); else loadDummyFile();
				case "xml":
					if (!xmls.exists(enqueued[i].name))   loadXml(enqueued[i]);   else loadDummyFile();
				case "music":
					if (!musics.exists(enqueued[i].name)) loadMusic(enqueued[i]); else loadDummyFile();
				case "sound":
					if (!sounds.exists(enqueued[i].name)) loadSound(enqueued[i]); else loadDummyFile();
				case "video":
					if (!videos.exists(enqueued[i].name)) loadVideo(enqueued[i]); else loadDummyFile();
				case "blob":
					if (!blobs.exists(enqueued[i].name))  loadBlob(enqueued[i]);  else loadDummyFile();
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
			if (loadFinished != null) loadFinished();
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
	
	private function loadImage(asset : Asset) { }
	private function loadBlob(asset : Asset) { }
	private function loadSound(asset : Asset) { }
	private function loadMusic(asset : Asset) { }
	private function loadVideo(asset : Asset) { }
	private function loadXml(asset : Asset) { }
	
	public function loadFont(name : String, style : FontStyle, size : Int) : Font { return null; }
	
	public function loadURL(url : String) : Void { }
	
	public function setNormalCursor() { }
	public function setHandCursor() { }
	public function setCursorBusy(busy : Bool) { }
	
	public function quit() : Void { }
}