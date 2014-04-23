package kha.psm;

import haxe.io.Bytes;

class Loader extends kha.Loader {
	override function loadMusic(desc: Dynamic, done: kha.Music -> Void): Void {
		done(new Music(desc.file));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(desc: Dynamic, done: kha.Sound -> Void): Void {
		done(new Sound(desc.file));
		--numberOfFiles;
		checkComplete();
	}

	override function loadImage(desc: Dynamic, done: kha.Image -> Void): Void {
		done(new Image(desc.file));
		--numberOfFiles;
		checkComplete();
	}

	@:functionCode('
		byte[] bytes = System.IO.File.ReadAllBytes("/Application/resources/" + filename);
		return new Blob(new haxe.io.Bytes(bytes.Length, bytes));
	')
	private function loadBlob2(filename: String): Blob {
		return null;
	}

	override function loadBlob(desc: Dynamic, done: kha.Blob -> Void): Void {
		done(loadBlob2(desc.file));
		--numberOfFiles;
		checkComplete();	
	}

	override public function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return null; //new Font(name, style, size);
	}
}
