package kha.cpp;

import kha.Blob;
import cpp.io.File;
import haxe.io.Bytes;
import kha.loader.Asset;

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
	
	override function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		return new kha.cpp.Font(name, style, size);
	}
}