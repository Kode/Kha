package kha.js;

import js.Boot;
import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.ImageElement;
import kha.FontStyle;
import kha.Blob;
import kha.Image;
import kha.Kravur;
import kha.Starter;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Lib;
import js.html.XMLHttpRequest;

class Loader extends kha.Loader {
	private var loadingBlobs: Map<String, Blob->Void>;
	private var loadingImages: Map<String, Image->Void>;
	private var loadingSounds: Map<String, Sound->Void>;
	private var loadingMusics: Map<String, Music->Void>;
	
	public function new() {
		super();
		loadingBlobs = new Map();
		loadingImages = new Map();
		loadingSounds = new Map();
		loadingMusics = new Map();
	}
	
	public function loadedBlob(value: Dynamic): Void {
		var blob = new Blob(Bytes.ofData(value.data));
		loadingBlobs[value.file](blob);
		loadingBlobs.remove(value.file);
	}
	
	public function loadedImage(value: Dynamic): Void {
		var image = new Image(value.id, value.width, value.height, value.realWidth, value.realHeight);
		loadingImages[value.file](image);
		loadingImages.remove(value.file);
	}
	
	public function loadedSound(value: Dynamic): Void {
		var sound = new Sound();
		loadingSounds[value.file](sound);
		loadingSounds.remove(value.file);
	}
	
	public function loadedMusic(value: Dynamic): Void {
		var music = new Music();
		loadingMusics[value.file](music);
		loadingMusics.remove(value.file);
	}
		
	override function loadMusic(desc: Dynamic, done: kha.Music -> Void) {
		loadingMusics[desc.file] = done;
		Worker.postMessage( { command: 'loadMusic', file: desc.file, name: desc.name } );
	}
	
	override function loadSound(desc: Dynamic, done: kha.Sound -> Void): Void {
		loadingSounds[desc.file] = done;
		Worker.postMessage( { command: 'loadSound', file: desc.file, name: desc.name } );
	}
	
	override function loadImage(desc: Dynamic, done: kha.Image -> Void) {
		loadingImages[desc.file] = done;
		Worker.postMessage( { command: 'loadImage', file: desc.file, name: desc.name } );
	}

	override function loadVideo(desc: Dynamic, done: kha.Video -> Void): Void {
		
	}
	
	override function loadBlob(desc: Dynamic, done: Blob -> Void) {
		loadingBlobs[desc.file] = done;
		Worker.postMessage( { command: 'loadBlob', file: desc.file, name: desc.name } );
	}
	
	override public function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return null;
	}

	override public function loadURL(url: String): Void {
		
	}
	
	override public function setNormalCursor() {
		
	}

	override public function setHandCursor() {
		
	}
}
