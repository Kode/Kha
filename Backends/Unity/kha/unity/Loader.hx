package kha.unity;

class Loader extends kha.Loader {
	public function new() {
		super();
	}
	
	override public function loadImage(desc: Dynamic, done: Image -> Void) { 
		done(Image.fromFilename(desc.file));
	}
	
	override public function loadBlob (desc: Dynamic, done: Blob  -> Void) { }
	override public function loadSound(desc: Dynamic, done: Sound -> Void) { }
	override public function loadMusic(desc: Dynamic, done: Music -> Void) { }
	override public function loadVideo(desc: Dynamic, done: Video -> Void) { }
}
