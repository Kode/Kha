package kha;

import haxe.io.Bytes;
import haxe.io.BytesData;
import kha.Blob;
import kha.Kravur;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/System.h>
#include <khalib/loader.h>
')

class BlobCallback {
	public var success: Blob -> Void;
	public var error: AssetError -> Void;

	public function new(success: Blob -> Void, error: AssetError -> Void) {
		this.success = success;
		this.error = error;
	}
}

class LoaderImpl {
	static var blobCallbacks = new Map<cpp.UInt64, BlobCallback>();

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void, failed: AssetError -> Void) {
		done(new kha.kore.Sound(desc.files[0]));
	}

	public static function getSoundFormats(): Array<String> {
		return ["wav", "ogg"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void, failed: AssetError -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		done(kha.Image.fromFile(desc.files[0], readable));
	}

	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void, failed: AssetError -> Void) {
		blobCallbacks[loadBlob(desc.files[0])] = new BlobCallback(done, failed);
	}

	@:functionCode('return kha_loader_load_blob(filename);')
	static function loadBlob(filename: String): cpp.UInt64 {
		return 0;
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void, failed: AssetError -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		}, failed);
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: Video -> Void, failed: AssetError -> Void) {
		done(new kha.kore.Video(desc.files[0]));
	}

	@:functionCode('return ::String(Kore::System::videoFormats()[0]);')
	private static function videoFormat(): String {
		return "";
	}

	public static function getVideoFormats(): Array<String> {
		return [videoFormat()];
	}

	@:functionCode('Kore::System::showKeyboard();')
	public static function showKeyboard(): Void {

	}

	@:functionCode('Kore::System::hideKeyboard();')
	public static function hideKeyboard(): Void {

	}

	@:functionCode('Kore::System::loadURL(url);')
	public static function loadURL(url: String): Void {

	}

	static function blobLoaded(index: cpp.UInt64, bytes: BytesData) {
		blobCallbacks[index].success(new Blob(Bytes.ofData(bytes)));
	}

	static function blobErrored(index: cpp.UInt64, filename: String) {
		blobCallbacks[index].error({url: filename});
	}

	@:functionCode('
		kha_file_reference_t file = kha_loader_get_file();
		while (file.index != 0) {
			if (file.error) {
				blobErrored(file.index, file.name);
			}
			else {
				Array<unsigned char> buffer = Array_obj<unsigned char>::fromData(file.data.blob.bytes, file.data.blob.size);
				blobLoaded(file.index, buffer);
			}
			file = kha_loader_get_file();
		}
	')
	public static function tick(): Void {

	}
}
