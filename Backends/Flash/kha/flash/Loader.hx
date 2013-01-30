package kha.flash;

import flash.net.NetStream;
import kha.Blob;
import kha.FontStyle;
import kha.loader.Asset;
import kha.Starter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import haxe.io.Bytes;

class Loader extends kha.Loader {
	public function new(main : Starter) {
		super();
	}
	
	override function loadMusic(asset: Asset) {
		var urlRequest : URLRequest = new URLRequest(asset.file + ".mp3");
		var music : flash.media.Sound = new flash.media.Sound();
		music.addEventListener(Event.COMPLETE, function(e : Event) {
			musics.set(asset.name, new Music(music));
			--numberOfFiles;
			checkComplete();
		});
		music.load(urlRequest);
	}
	
	override function loadXml(asset: Asset) {
		var urlRequest : URLRequest = new URLRequest(asset.file);
		var urlLoader : URLLoader = new URLLoader();
		urlLoader.addEventListener(Event.COMPLETE, function(e : Event) {
			xmls.set(asset.name, Xml.parse(urlLoader.data));
			--numberOfFiles;
			checkComplete();
		});
		urlLoader.load(urlRequest);
	}
	
	override function loadImage(asset: Asset) {
		var urlRequest : URLRequest = new URLRequest(asset.file);
		var loader : flash.display.Loader = new flash.display.Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e : Event) {
			images.set(asset.name, new Image(loader.content));
			--numberOfFiles;
			checkComplete();
		});
		loader.load(urlRequest);
	}
	
	override function loadBlob(asset: Asset) {
		var urlRequest : URLRequest = new URLRequest(asset.file);
		var urlLoader : URLLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, function(e: Event) {
			var blob = new Blob(Bytes.ofData(urlLoader.data));
			blobs.set(asset.name, blob);
			--numberOfFiles;
			checkComplete();
		});
		urlLoader.load(urlRequest);
	}

	override function loadSound(asset: Asset) {
		var urlRequest : URLRequest = new URLRequest(asset.file + ".mp3");
		var sound : flash.media.Sound = new flash.media.Sound();
		sound.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e : flash.events.ErrorEvent) {
			trace ("Couldn't load " + asset.file + ".mp3");
			--numberOfFiles;
			checkComplete();
		});
		sound.addEventListener(Event.COMPLETE, function(e : Event) {
			sounds.set(asset.name, new Sound(sound));
			--numberOfFiles;
			checkComplete();
		});
		sound.load(urlRequest);
	}

	override function loadVideo(asset: Asset) {
		videos.set(asset.name, new Video(asset.file + ".mp4"));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		return new kha.flash.Font(name, style, size);
	}
  
	override public function loadURL(url: String): Void {
		try {
			flash.Lib.getURL(new flash.net.URLRequest(url), "_top");
		}
		catch (ex: Dynamic) {
			trace(ex);
		}
	}
	
	/*function loadDataXml() : Void {
		var urlRequest : URLRequest = new URLRequest("project.kha");
		var urlLoader : URLLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, function(e : Event) {
			var blob = new Blob(Bytes.ofData(urlLoader.data));
			blobs.set("project.kha", blob);
			if (isPreLoad)
				loadWindowSize();
			else
				loadFiles();
		});
		urlLoader.load(urlRequest);
	}*/
	
	override function setNormalCursor() {
		Mouse.cursor = "auto";
	}
	
	override function setHandCursor() {
		Mouse.cursor = "button";
	}
	
	override function setCursorBusy(busy: Bool) {
		if (busy)
			Mouse.hide();
		else
			Mouse.show();
	}
}