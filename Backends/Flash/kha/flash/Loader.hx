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
			done(new Image(loader.content));
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
		sound.addEventListener(Event.COMPLETE, function(e : Event) {
			done(new Sound(sound));
		});
		sound.load(urlRequest);
	}

	override function loadVideo(filename: String, done: kha.Video -> Void) {
		done(new Video(filename + ".mp4"));
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