package kha;

import haxe.io.Bytes;

class LoaderImpl {
	public static function loadImageFromDescription(desc: Dynamic, done: Image -> Void): Void { 
		done(Image.fromFilename(desc.files[0], desc.original_width, desc.original_height));
	}
	
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg"];
	}
	
	public static function loadBlobFromDescription(desc: Dynamic, done: Blob  -> Void): Void {
		done(new Blob(Bytes.ofData(UnityBackend.loadBlob(desc.files[0]))));
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		});
	}
	
	public static function loadSoundFromDescription(desc: Dynamic, done: Sound -> Void): Void {
		done(new kha.unity.Sound(desc.files[0]));
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["wav", "ogg"];
	}
	
	public static function loadVideoFromDescription(desc: Dynamic, done: Video -> Void): Void {
		done(new Video());
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["mp4"];
	}
}
