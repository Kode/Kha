package kha;

import flash.net.NetStream;
import kha.Blob;
import kha.FontStyle;
import kha.Kravur;
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

class LoaderImpl {
	/*public function new(main: Starter) {
		super();
		#if KHA_EMBEDDED_ASSETS
		Assets.visit();
		#end
	}*/
	
	private static function adjustFilename(filename: String): String {
		filename = filename.replace(".", "_");
		filename = filename.replace("-", "_");
		filename = filename.replace("/", "_");
		return filename;
	}
	
	/*public static function loadMusicFromDescription(desc: Dynamic, done: kha.Music -> Void) {
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.files[0]);
		done(new kha.flash.Music(Bytes.ofData(cast Type.createInstance(Type.resolveClass("Assets_" + file), []))));
		
		#else
		
		var mp3file: String = null;
		var oggfile: String = null;
		for (i in 0...desc.files.length) {
			var file: String = desc.files[i];
			if (file.endsWith(".ogg")) {
				oggfile = file;
			}
			if (file.endsWith(".mp3")) {
				mp3file = file;
			}
		}
		
		var urlRequest = new URLRequest(oggfile);
		var urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, function(e: Event) {
			var music = new kha.flash.Music(Bytes.ofData(urlLoader.data));
			if (mp3file == null) {
				done(music);
			}
			else {
				var urlRequest = new URLRequest(mp3file);
				var flashmusic = new flash.media.Sound();
				flashmusic.addEventListener(Event.COMPLETE, function(e: Event) {
					music._nativemusic = flashmusic;
					done(music);
				});
				flashmusic.load(urlRequest);
			}
		});
		urlLoader.load(urlRequest);

		#end
	}*/
	
	public static function loadImageFromDescription(desc: Dynamic, done: Image -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.files[0]);
		done(Image.fromBitmapData(cast Type.createInstance(Type.resolveClass("Assets_" + file), [0, 0]), readable));

		#else
		
		var urlRequest = new URLRequest(desc.files[0]);
		var loader = new flash.display.Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e: Event) {
			done(Image.fromBitmap(loader.content, readable));
		});
		loader.load(urlRequest);
		
		#end
	}
	
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg"];
	}
	
	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void) {
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.files[0]);
		done(new Blob(Bytes.ofData(cast Type.createInstance(Type.resolveClass("Assets_" + file), []))));
		
		#else
		
		var urlRequest = new URLRequest(desc.files[0]);
		var urlLoader = new URLLoader();
		urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
		urlLoader.addEventListener(Event.COMPLETE, function(e: Event) {
			done(new Blob(urlLoader.data));
		});
		urlLoader.load(urlRequest);
		
		#end
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		});
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void) {
		#if KHA_EMBEDDED_ASSETS
		
		var file: String = adjustFilename(desc.files[0]);
		done(new kha.flash.Sound(Bytes.ofData(cast Type.createInstance(Type.resolveClass("Assets_" + file), []))));
		
		#else
		
		/*var urlRequest = new URLRequest(desc.file + ".mp3");
		var sound = new flash.media.Sound();
		sound.addEventListener(flash.events.IOErrorEvent.IO_ERROR, function(e: flash.events.ErrorEvent) {
			trace ("Couldn't load " + desc.file + ".mp3");
			done(new Sound(sound));
		});
		sound.addEventListener(Event.COMPLETE, function(e : Event) {
			done(new Sound(sound));
		});
		sound.load(urlRequest);*/
		
		for (i in 0...desc.files.length) {
			var file: String = desc.files[i];
			if (file.endsWith(".ogg")) {
				var urlRequest = new URLRequest(file);
				var urlLoader = new URLLoader();
				urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
				urlLoader.addEventListener(Event.COMPLETE, function(e: Event) {
					done(new kha.flash.Sound(Bytes.ofData(urlLoader.data)));
				});
				urlLoader.load(urlRequest);
			}
		}
		
		#end
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["ogg"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void) {
		done(new kha.flash.Video(desc.files[0]));
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["mp4"];
	}
	
	/*override function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
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
	}*/
}
