package kha.cpp;

import kha.Blob;
import haxe.io.Bytes;
import kha.loader.Asset;
import sys.io.File;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/System.h>
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
		done(new kha.cpp.Image(filename));
	}
	
	override function loadBlob(filename: String, done: Blob -> Void) {
		done(new Blob(File.getBytes(filename)));
	}

	override private function loadVideo(asset: Asset): Void {
		videos.set(asset.name, new Video(asset.file));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		return new kha.cpp.Font(name, style, size);
	}

	@:functionCode('Kt::System::showKeyboard();')
	override public function showKeyboard(): Void {

	}

	@:functionCode('Kt::System::hideKeyboard();')
	override public function hideKeyboard(): Void {

	}
}
