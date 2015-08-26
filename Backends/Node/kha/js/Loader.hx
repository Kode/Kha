package kha.js;

import js.Boot;
import js.Browser;
import js.Error;
import js.html.audio.DynamicsCompressorNode;
import js.html.ImageElement;
import js.Node;
import js.node.Buffer;
import js.node.Fs;
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
	public function new() {
		super();
	}
		
	override function loadMusic(desc: Dynamic, done: kha.Music -> Void) {
		Node.setTimeout(function () {
			done(new Music());
		}, 0);
	}
	
	override function loadSound(desc: Dynamic, done: kha.Sound -> Void): Void {
		Node.setTimeout(function () {
			done(new Sound());
		}, 0);
	}		
	
	override function loadImage(desc: Dynamic, done: kha.Image -> Void) {
		Node.setTimeout(function () {
			done(new Image(100, 100));
		}, 0);
	}

	override function loadVideo(desc: Dynamic, done: kha.Video -> Void): Void {
		Node.setTimeout(function () {
			done(new Video());
		}, 0);
	}
	
	override function loadBlob(desc: Dynamic, done: Blob -> Void) {
		Fs.readFile(desc.files[0], function (error: Error, data: Buffer) {
			done(Blob.fromBuffer(data));
		});
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
