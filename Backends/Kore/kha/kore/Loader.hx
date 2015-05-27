package kha.kore;

import kha.Blob;
import haxe.io.Bytes;
import kha.Kravur;
import sys.io.File;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/System.h>
')

class Loader extends kha.Loader {
	public function new() {
		super();
	}
	
	override function loadMusic(desc: Dynamic, done: kha.Music -> Void) {
		done(new Music(desc.file));
	}
	
	override function loadSound(desc: Dynamic, done: kha.Sound -> Void) {
		done(new Sound(desc.file));
	}
	
	override function loadImage(desc: Dynamic, done: kha.Image -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		done(kha.Image.fromFile(desc.file, readable));
	}
	
	override function loadBlob(desc: Dynamic, done: Blob -> Void) {
		done(new Blob(File.getBytes(desc.file)));
	}
	
	override function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return Kravur.get(name, style, size);
	}
	
	override public function loadVideo(desc: Dynamic, done: Video -> Void) {
		done(new Video(desc.file));
	}

	@:functionCode('Kore::System::showKeyboard();')
	override public function showKeyboard(): Void {

	}

	@:functionCode('Kore::System::hideKeyboard();')
	override public function hideKeyboard(): Void {

	}

	@:functionCode('Kore::System::loadURL(url);')
	override public function loadURL(url : String): Void {

	}
}
