package kha;

import kha.Blob;
import haxe.io.Bytes;
import kha.Kravur;
import sys.io.File;

class LoaderImpl {
	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound->Void, failed: AssetError->Void) {
		done(new kha.korehl.Sound(desc.files[0]));
	}

	public static function getSoundFormats(): Array<String> {
		return ["wav", "ogg"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image->Void, failed: AssetError->Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		done(kha.Image.fromFile(desc.files[0], readable));
	}

	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob->Void, failed: AssetError->Void) {
		// done(new Blob(File.getBytes(desc.files[0])));
		var size = 0;
		var bytes = kore_file_contents(StringHelper.convert(desc.files[0]), size);
		done(new Blob(@:privateAccess new haxe.io.Bytes(bytes, size)));
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font->Void, failed: AssetError->Void): Void {
		loadBlobFromDescription(desc, function(blob: Blob) {
			done(new Kravur(blob));
		}, failed);
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: Video->Void, failed: AssetError->Void) {
		done(new kha.korehl.Video(desc.files[0]));
	}

	public static function getVideoFormats(): Array<String> {
		return [StringHelper.fromBytes(kore_video_format())];
	}

	@:hlNative("std", "kore_file_contents") static function kore_file_contents(name: hl.Bytes, size: hl.Ref<Int>): Pointer {
		return null;
	}

	@:hlNative("std", "kore_video_format") static function kore_video_format(): Pointer {
		return null;
	}
}
