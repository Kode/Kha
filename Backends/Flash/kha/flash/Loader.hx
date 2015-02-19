package kha.flash;

import flash.net.NetStream;
import kha.Blob;
import kha.FontStyle;
import kha.Game;
import kha.Kravur;
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

using StringTools;

class Loader extends kha.Loader {
	public function new(main: Starter) {
		super();
		#if KHA_EMBEDDED_ASSETS
		Assets.visit();
		#end
		isQuitable = true;
	}
	
	private static function adjustFilename(filename: String): String {
		filename = filename.replace(".", "_");
		filename = filename.replace("-", "_");
		filename = filename.replace("/", "_");
		return filename;
	}
	
	override function loadMusic(desc: Dynamic, done: kha.Music -> Void) {
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.file + ".mp3");
		done(new Music(cast Type.createInstance(Type.resolveClass("Assets_" + file), [])));
		
		#else
		
		var urlRequest = new URLRequest(desc.file + ".mp3");
		var music = new flash.media.Sound();
		music.addEventListener(Event.COMPLETE, function(e : Event) {
			done(new Music(music));
		});
		music.load(urlRequest);
		
		#end
	}
	
	override function loadImage(desc: Dynamic, done: Image -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.file);
		done(Image.fromBitmapData(cast Type.createInstance(Type.resolveClass("Assets_" + file), [0, 0]), readable));

		#else
		
		var urlRequest = new URLRequest(desc.file);
		var loader = new flash.display.Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e: Event) {
			done(Image.fromBitmap(loader.content, readable));
		});
		loader.load(urlRequest);
		
		#end
	}
	
	override function loadBlob(desc: Dynamic, done: Blob -> Void) {
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.file);
		done(new Blob(Bytes.ofData(cast Type.createInstance(Type.resolveClass("Assets_" + file), []))));
		
		#else
		
		var urlRequest = new URLRequest(desc.file);
		var urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, function(e: Event) {
			done(new Blob(Bytes.ofData(urlLoader.data)));
		});
		urlLoader.load(urlRequest);
		
		#end
	}

	override function loadSound(desc: Dynamic, done: kha.Sound -> Void) {
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.file + ".mp3");
		done(new Sound(cast Type.createInstance(Type.resolveClass("Assets_" + file), [])));
		
		#else
		
		var urlRequest = new URLRequest(desc.file + ".mp3");
		var sound = new flash.media.Sound();
		sound.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e: flash.events.ErrorEvent) {
			trace ("Couldn't load " + desc.file + ".mp3");
			done(new Sound(sound));
		});
		sound.addEventListener(Event.COMPLETE, function(e : Event) {
			done(new Sound(sound));
		});
		sound.load(urlRequest);
		
		#end
	}

	override function loadVideo(desc: Dynamic, done: kha.Video -> Void) {
		done(new Video(desc.file + ".mp4"));
	}
	
	override function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return Kravur.get(name, style, size);
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
		Game.the.onPause();
		Game.the.onBackground();
		Game.the.onShutdown();
		flash.Lib.fscommand("quit");
	}
}
