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

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image->Void, failed: AssetError->Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		done(Image._fromTexture(Krom.loadImage(desc.files[0], readable)));
	}

	public static function getSoundFormats(): Array<String> {
		return ["wav", "ogg"];
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound->Void, failed: AssetError->Void) {
		done(new kha.krom.Sound(Bytes.ofData(Krom.loadSound(desc.files[0]))));
	}

	public static function getVideoFormats(): Array<String> {
		return ["webm"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video->Void, failed: AssetError->Void): Void {}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob->Void, failed: AssetError->Void) {
		done(new Blob(Bytes.ofData(Krom.loadBlob(desc.files[0]))));
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font->Void, failed: AssetError->Void): Void {
		loadBlobFromDescription(desc, function(blob: Blob) {
			done(new Kravur(blob));
		}, failed);
	}
}
