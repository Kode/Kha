package kha.flash;

import flash.net.NetStream;
import kha.Blob;
import kha.FontStyle;
import kha.Game;
import kha.Kravur;
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
	private var fontCache: Map<String, Kravur>;
	
	public function new(main: Starter) {
		super();
		isQuitable = true;
		fontCache = new Map<String, Kravur>();
	}
	
	override function loadMusic(filename: String, done: kha.Music -> Void) {
		var urlRequest = new URLRequest(filename + ".mp3");
		var music = new flash.media.Sound();
		music.addEventListener(Event.COMPLETE, function(e : Event) {
			done(new Music(music));
		});
		music.load(urlRequest);
	}
	
	override function loadImage(filename: String, done: Image -> Void) {
		var urlRequest = new URLRequest(filename);
		var loader = new flash.display.Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e : Event) {
			done(Image.fromBitmap(loader.content));
		});
		loader.load(urlRequest);
	}
	
	override function loadBlob(filename: String, done: Blob -> Void) {
		var urlRequest = new URLRequest(filename);
		var urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, function(e: Event) {
			done(new Blob(Bytes.ofData(urlLoader.data)));
		});
		urlLoader.load(urlRequest);
	}

	override function loadSound(filename: String, done: kha.Sound -> Void) {
		var urlRequest = new URLRequest(filename + ".mp3");
		var sound = new flash.media.Sound();
		sound.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e: flash.events.ErrorEvent) {
			trace ("Couldn't load " + filename + ".mp3");
			done(new Sound(sound));
		});
		sound.addEventListener(Event.COMPLETE, function(e : Event) {
			done(new Sound(sound));
		});
		sound.load(urlRequest);
	}

	override function loadVideo(filename: String, done: kha.Video -> Void) {
		done(new Video(filename + ".mp4"));
	}
	
	override function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		var fontName = name + size;
		if (!fontCache.exists(fontName)) {
			fontCache.set(fontName, new Kravur(name, style, size));
		}
		return fontCache[fontName];
	}
  
	override public function loadURL(url: String): Void {
		try {
			flash.Lib.getURL(new flash.net.URLRequest(url), "_top");
		}
		catch (ex: Dynamic) {
			trace(ex);
		}
	}
	
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

	override public function quit(): Void {
		Game.the.onClose();
		flash.Lib.fscommand("quit");
		//flash.system.FSCommand()._fscommand("quit","");
	}
}
