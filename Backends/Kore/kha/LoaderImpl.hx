package kha;

import kha.Blob;
import haxe.io.Bytes;
import kha.Kravur;
import sys.io.File;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/System.h>
')

class LoaderImpl {
	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void, failed: Dynamic -> Void) {
		try
			done(new kha.kore.Sound(desc.files[0]))
		catch (x: Dynamic)
			failed(x);
	}

	public static function getSoundFormats(): Array<String> {
		return ["wav", "ogg"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void, failed: Dynamic -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		try
			done(kha.Image.fromFile(desc.files[0], readable))
		catch (x: Dynamic)
			failed(x);
	}

	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void, failed: Dynamic -> Void) {
		try
			done(new Blob(File.getBytes(desc.files[0])))
		catch (x: Dynamic)
			failed(x);
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void, failed: Dynamic -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		}, failed);
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: Video -> Void, failed: Dynamic -> Void) {
		try
			done(new kha.kore.Video(desc.files[0]))
		catch (x: Dynamic)
			failed(x);
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
}
