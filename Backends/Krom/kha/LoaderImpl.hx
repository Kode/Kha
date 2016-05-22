package kha;

import kha.FontStyle;
import kha.Blob;
import kha.Kravur;
import haxe.io.Bytes;
import haxe.io.BytesData;

class LoaderImpl {
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg"];
	}
	
	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void) {
		done(Image._fromTexture(Krom.loadImage(desc.files[0])));
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["ogg"];
	}
	
	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void) {
		//done(Krom.loadSound(desc.files[0]));
		done(new kha.krom.Sound());
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["webm"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void): Void {
		
	}
    
	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void) {
		done(new Blob(Bytes.ofData(Krom.loadBlob(desc.files[0]))));
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		});
	}
}
