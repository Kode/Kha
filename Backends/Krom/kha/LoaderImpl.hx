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
		var texture = Krom.loadImage(desc.files[0], readable);
		if (texture == null) {
			failed({
				url: desc.files.join(","),
				error: "Could not load image(s)",
			});
		}
		else {
			done(Image._fromTexture(texture));
		}
	}

	public static function getSoundFormats(): Array<String> {
		return ["wav", "ogg"];
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound->Void, failed: AssetError->Void) {
		var sound = Krom.loadSound(desc.files[0]);
		if (sound == null) {
			failed({
				url: desc.files.join(","),
				error: "Could not load sound(s)",
			});
		}
		else {
			done(new kha.krom.Sound(Bytes.ofData(sound)));
		}
	}

	public static function getVideoFormats(): Array<String> {
		return ["webm"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video->Void, failed: AssetError->Void): Void {
		failed({
			url: desc.files.join(","),
			error: "Could not load video(s), Krom currently does not support loading videos",
		});
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob->Void, failed: AssetError->Void) {
		var blob = Krom.loadBlob(desc.files[0]);
		if (blob == null) {
			failed({
				url: desc.files.join(","),
				error: "Could not load blob(s)",
			});
		}
		else {
			done(new Blob(Bytes.ofData(blob)));
		}
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font->Void, failed: AssetError->Void): Void {
		loadBlobFromDescription(desc, function(blob: Blob) {
			done(new Kravur(blob));
		}, (a: AssetError) -> {
			a.error = "Could not load font(s)";
			failed(a);
		});
	}
}
