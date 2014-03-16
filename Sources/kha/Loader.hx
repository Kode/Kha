package kha;

import haxe.Json;
import kha.loader.Room;

@:expose
class Loader {
	var blobs: Map<String, Blob>;
	var images: Map<String, Image>;
	var sounds: Map<String, Sound>;
	var musics: Map<String, Music>;
	var videos: Map<String, Video>;
	var shaders: Map<String, Blob>;
	var loadcount: Int;
	var numberOfFiles: Int;
	
	var assets: Map<String, Dynamic>;
	var rooms: Map<String, Room>;
	public var isQuitable : Bool = false; // Some backends dont support quitting, for example if the game is embedded in a webpage
	public var autoCleanupAssets : Bool = true;

	public function new() {
		blobs = new Map<String, Blob>();
		images = new Map<String, Image>();
		sounds = new Map<String, Sound>();
		musics = new Map<String, Music>();
		videos = new Map<String, Video>();
		assets = new Map<String, Dynamic>();
		shaders = new Map<String, Blob>();
		rooms = new Map<String, Room>();
		enqueued = new Array<Dynamic>();
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
		if (!images.exists(name) && name != "") {
			trace("Could not find image " + name + ".");
		}
		return images.get(name);
	}
	
	public function getMusic(name : String) : Music {
		return musics.get(name);
	}
	
	public function getSound(name : String) : Sound {
		if (name != "" && !sounds.exists(name)) {
			trace("Sound '" + name + "' not found");
		}
		return sounds.get(name);
	}
	
	public function getVideo(name : String) : Video {
		return videos.get(name);
	}
	
	public function getShader(name: String): Blob {
		return shaders.get(name);
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
	
	private var enqueued: Array<Dynamic>;
	public var loadFinished: Void -> Void;
	
	public function enqueue(asset: Dynamic) {
		if (!Lambda.has(enqueued, asset)) {
			enqueued.push(asset);
		}
	}
	
	public static function containsAsset(assetName: String, assetType: String, map: Array<Dynamic>): Bool {
		for (asset in map) {
			if (asset.type == assetType && asset.name == assetName) return true;
		}
		return false;
	}
	
	private function removeImage(resources: Map<String, Image>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeBlob(resources: Map<String, Blob>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeMusic(resources: Map<String, Music>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeSound(resources: Map<String, Sound>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}
	
	private function removeVideo(resources: Map<String, Video>, resourceName: String) {
		var resource = resources.get(resourceName);
		resource.unload();
		resources.remove(resourceName);
	}

	public function cleanup(): Void {
		for (imagename in images.keys()) if (!containsAsset(imagename, "image", enqueued)) removeImage(images, imagename);
		for (musicname in musics.keys()) if (!containsAsset(musicname, "music", enqueued)) removeMusic(musics, musicname);
		for (soundname in sounds.keys()) if (!containsAsset(soundname, "sound", enqueued)) removeSound(sounds, soundname);
		for (videoname in videos.keys()) if (!containsAsset(videoname, "video", enqueued)) removeVideo(videos, videoname);
		for (blobname  in blobs.keys())  if (!containsAsset(blobname,  "blob",  enqueued)) removeBlob(blobs, blobname);

		enqueued = new Array<Dynamic>();
	}
	
	public function loadFiles(call: Void -> Void, autoCleanup: Bool) {
		loadFinished = call;
		loadStarted(enqueued.length);
		
		if (enqueued.length > 0) {
			for (i in 0...enqueued.length) {
				switch (enqueued[i].type) {
					case "image":
						if (!images.exists(enqueued[i].name)) {
							var imageName = enqueued[i].name;
							//trace ('image to load: "$imageName"');
							loadImage(enqueued[i], function(image: Image) {
								if (!images.exists(imageName)) {
									//trace ('loaded image "$imageName"');
									images.set(imageName, image);
									--numberOfFiles;
									checkComplete();
								}
							});
						}
						else loadDummyFile();
					case "music":
						if (!musics.exists(enqueued[i].name)) {
							var musicName = enqueued[i].name;
							//trace ('music to load: "$musicName"');
							loadMusic(enqueued[i], function(music: Music) {
								if (!musics.exists(musicName)) {
									//trace ('loaded music "$musicName"');
									musics.set(musicName, music);
									--numberOfFiles;
									checkComplete();
								}
							});
						}
						else loadDummyFile();
					case "sound":
						if (!sounds.exists(enqueued[i].name)) {
							var soundName = enqueued[i].name;
							//trace ('sound to load: "$soundName"');
							loadSound(enqueued[i], function(sound: Sound) {
								if (!sounds.exists(soundName)) {
									//trace ('loaded sound "$soundName"');
									sounds.set(soundName, sound);
									--numberOfFiles;
									checkComplete();
								}
							});
						}
						else loadDummyFile();
					case "video":
						if (!videos.exists(enqueued[i].name)) {
							var videoName = enqueued[i].name;
							//trace ('video to load: "$videoName"');
							loadVideo(enqueued[i], function(video: Video) {
								if (!videos.exists(videoName)) {
									//trace ('loaded video "$videoName"');
									videos.set(videoName, video);
									--numberOfFiles;
									checkComplete();
								}
							});
						}
						else loadDummyFile();
					case "blob":
						if (!blobs.exists(enqueued[i].name)) {
							var blobName = enqueued[i].name;
							//trace ('blob to load: "$blobName"');
							loadBlob(enqueued[i], function(blob: Blob) {
								if (!blobs.exists(blobName)) {
									//trace ('loaded blob "$blobName"');
									blobs.set(blobName, blob);
									--numberOfFiles;
									checkComplete();
								}
							});
						}
						else loadDummyFile();
				}
			}
		}
		else {
			checkComplete();
		}
		
		if (autoCleanup) cleanup();
	}
	
	public function loadProject(call: Void -> Void) {
		enqueue({name: "project.kha", file: "project.kha", type: "blob"});
		loadFiles(function() { loadShaders(call); }, false);
	}
	
	private function loadShaders(call: Void -> Void): Void {
		var project = parseProject();
		if (project.shaders != null && project.shaders.length > 0) {
			var shaders: Dynamic = project.shaders;
			var shaderCount: Int = shaders.length;
			for (i in 0...shaders.length) {
				var shader = shaders[i];
				//trace ('shader to load: "${shader.name}"');
				loadBlob(shader, function(blob: Blob) {
					if (!this.shaders.exists(shader.name)) { //Chrome tends to call finished loading callbacks multiple times
						//trace ('loaded shader "${shader.name}"');
						this.shaders.set(shader.name, blob);
						--shaderCount;
						if (shaderCount == 0) call();
					}
				} );
			}
		}
		else call();
	}
	
	private function loadRoomAssets(room: Room) {
		for (i in 0...room.assets.length) {
			enqueue(room.assets[i]);
		}
		if (room.parent != null) loadRoomAssets(room.parent);
	}
	
	public function loadRoom(name: String, call: Void -> Void) {
		loadRoomAssets(rooms.get(name));
		loadFiles(call, autoCleanupAssets);
	}
	
	public function initProject() {
		var project = parseProject();
		name = project.game.name;
		width = project.game.width;
		height = project.game.height;
		var assets: Dynamic = project.assets;
		for (i in 0...assets.length) {
			this.assets.set(assets[i].id, assets[i]);
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
		//trace ( "Files Left: " + numberOfFiles );
		if (numberOfFiles <= 0) {
			if (loadFinished != null) loadFinished();
		}
	}
	
	function loadDummyFile(): Void {
		--numberOfFiles;
		checkComplete();
	}
	
	function loadStarted(numberOfFiles: Int) {
		if (numberOfFiles > 0) {
			this.loadcount = numberOfFiles;
			this.numberOfFiles = numberOfFiles;
		} else {
			this.loadcount = 1;
			this.numberOfFiles = 0;
		}
	}
	
	public function loadImage(desc: Dynamic, done: Image -> Void) { }
	public function loadBlob (desc: Dynamic, done: Blob  -> Void) { }
	public function loadSound(desc: Dynamic, done: Sound -> Void) { }
	public function loadMusic(desc: Dynamic, done: Music -> Void) { }
	public function loadVideo(desc: Dynamic, done: Video -> Void) { }
	
	public function loadFont(name : String, style : FontStyle, size : Float) : Font { return null; }
	
	public function loadURL(url : String) : Void { }
	
	public function setNormalCursor() { }
	public function setHandCursor() { }
	public function setCursorBusy(busy : Bool) { }
	
	public function showKeyboard(): Void { }
	public function hideKeyboard(): Void { }

	public function quit() : Void { }
}
