package kha.cpp;

import kha.Blob;
import haxe.io.Bytes;
import kha.Kravur;
import kha.loader.Asset;
import sys.io.File;

class Loader extends kha.Loader {
	public function new() {
		super();
	}
	
	override function loadMusic(filename: String, done: kha.Music -> Void) {
		done(new Music(filename));
	}
	
	override function loadSound(filename: String, done: kha.Sound -> Void) {
		done(new Sound(filename));
	}
	
	override function loadImage(filename: String, done: kha.Image -> Void) {
		done(kha.cpp.Image.fromFile(filename));
	}
	
	override function loadBlob(filename: String, done: Blob -> Void) {
		done(new Blob(File.getBytes(filename)));
	}
	
	override function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		return new Kravur(name, style, size);
	}
}
