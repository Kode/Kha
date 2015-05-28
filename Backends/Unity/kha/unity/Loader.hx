package kha.unity;

import haxe.io.Bytes;
import kha.Blob;

class Loader extends kha.Loader {
	public function new() {
		super();
	}
	
	override public function loadImage(desc: Dynamic, done: Image -> Void) { 
		done(Image.fromFilename(desc.file, desc.original_width, desc.original_height));
	}
	
	override public function loadBlob (desc: Dynamic, done: Blob  -> Void) {
		done(new Blob(Bytes.ofData(UnityBackend.loadBlob(desc.file))));
	}
	
	override public function loadSound(desc: Dynamic, done: Sound -> Void) {
		done(new Sound());
	}
	
	override public function loadMusic(desc: Dynamic, done: Music -> Void) {
		done(new Music());
	}

	override public function loadVideo(desc: Dynamic, done: Video -> Void) {
		done(new Video());
	}
}
