package kha.cpp;

import kha.Blob;
import haxe.io.Bytes;
import kha.Kravur;
import kha.loader.Asset;
import sys.io.File;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/System.h>
')

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
	
	override function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return Kravur.get(name, style, size);
	}
	
	override public function loadVideo(filename: String, done: Video -> Void) {
		done(new Video());
	}

	@:functionCode('Kore::System::showKeyboard();')
	override public function showKeyboard(): Void {

	}

	@:functionCode('Kore::System::hideKeyboard();')
	override public function hideKeyboard(): Void {

	}
}
