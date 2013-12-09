package kha.psm;

import haxe.io.Bytes;
import kha.loader.Asset;

class Loader extends kha.Loader {
	override function loadMusic(filename: String, done: kha.Music -> Void): Void {
		done(new Music(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(filename: String, done: kha.Sound -> Void): Void {
		done(new Sound(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadImage(filename: String, done: kha.Image -> Void): Void {
		done(new Image(filename));
		--numberOfFiles;
		checkComplete();
	}

	@:functionBody('
		byte[] bytes = System.IO.File.ReadAllBytes("/Application/resources/" + asset.file);
		blobs.set(asset.name, new Blob(new haxe.io.Bytes(bytes.Length, bytes)));
		--numberOfFiles;
		checkComplete();
	')
	override function loadBlob(filename: String, done: kha.Blob -> Void): Void {
		
	}

	override public function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return null; //new Font(name, style, size);
	}
}
