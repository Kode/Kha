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
		
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["mp4", "ogg"];
	}
	
	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void) {
		
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["mp4", "webm"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void): Void {
		
	}
    
	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void) {
		
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void): Void {
		
	}
}
