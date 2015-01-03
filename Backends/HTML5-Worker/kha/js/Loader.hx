package kha.js;

import js.Boot;
import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.ImageElement;
import kha.FontStyle;
import kha.Blob;
import kha.Kravur;
import kha.Starter;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Lib;
import js.html.XMLHttpRequest;

class Loader extends kha.Loader {
	private var files: Map<String, Dynamic>;
	
	public function new() {
		super();
	}
	
	public function loaded(filename: String): Void {
		files[filename](null);
	}
		
	override function loadMusic(desc: Dynamic, done: kha.Music -> Void) {
		new Music(desc.file, done);
	}
	
	override function loadSound(desc: Dynamic, done: kha.Sound -> Void): Void {
		Worker.postMessage( { command: 'loadSound', file: desc.file } );
	}
	
	override function loadImage(desc: Dynamic, done: kha.Image -> Void) {
		Worker.postMessage( { command: 'loadImage', file: desc.file } );
	}

	override function loadVideo(desc: Dynamic, done: kha.Video -> Void): Void {
		
	}
	
	override function loadBlob(desc: Dynamic, done: Blob -> Void) {
		Worker.postMessage( { command: 'loadBlob', file: desc.file } );
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
