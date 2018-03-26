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

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void, failed: Dynamic -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		try
			done(Image._fromTexture(Krom.loadImage(desc.files[0], readable)))
		catch (x: Dynamic)
			failed(x);
	}

	public static function getSoundFormats(): Array<String> {
		return ["wav", "ogg"];
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void, failed: Dynamic -> Void) {
		try
			done(new kha.krom.Sound(Bytes.ofData(Krom.loadSound(desc.files[0]))))
		catch (x: Dynamic)
			failed(x);
	}

	public static function getVideoFormats(): Array<String> {
		return ["webm"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void, failed: Dynamic -> Void): Void {

	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void, failed: Dynamic -> Void) {
		try
			done(new Blob(Bytes.ofData(Krom.loadBlob(desc.files[0]))))
		catch (x: Dynamic)
			failed(x);
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void, failed: Dynamic -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		}, failed);
	}
}
