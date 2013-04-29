package kha.cpp;

import kha.Blob;
import sys.io.File;
import haxe.io.Bytes;
import kha.loader.Asset;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/System.h>
')

class Loader extends kha.Loader {
	public function new() {
		super();
	}
	
	override function loadXml(asset: Asset) {
		xmls.set(asset.name, Xml.parse(File.getContent(asset.file)));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadMusic(asset: Asset) {
		musics.set(asset.name, new Music(asset.file));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadSound(asset: Asset) {
		sounds.set(asset.name, new Sound(asset.file));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadImage(asset: Asset) {
		images.set(asset.name, new kha.cpp.Image(asset.file));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadBlob(asset: Asset) {
		blobs.set(asset.name, new Blob(File.getBytes(asset.file)));
		--numberOfFiles;
		checkComplete();
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