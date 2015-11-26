package kha;

import haxe.CallStack;
import haxe.io.Bytes;
import haxe.io.BytesData;
import haxe.Json;
import kha.Blob;
import kha.FontStyle;
import kha.Kravur;
import system.io.File;
import system.windows.FrameworkElement;
import system.windows.input.Cursor;
import system.windows.input.Cursors;
import system.windows.input.Mouse;

class LoaderImpl {
	public static var path: String = "";
	public static var forceBusyCursor: Bool = false;
	private static var savedCursor: Cursor;
	private static var busyCursor: Bool = false;
	
	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void): Void {
		done(new kha.wpf.Sound(path + desc.files[0]));
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["wav"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void): Void {
		done(Image.fromFilename(path + desc.files[0]));
	}
	
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg"];
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: kha.Blob -> Void): Void {
		done(new Blob(Bytes.ofData(File.ReadAllBytes(path + desc.files[0]))));
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void): Void {
		done(new kha.wpf.Video(path + desc.files[0]));
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["wmv"];
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: kha.Font -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		});
	}

	@:functionCode('global::System.Diagnostics.Process.Start(new global::System.Uri(url).AbsoluteUri);')
	public static function loadURL(url: String): Void {
		
	}

	public static function setNormalCursor() {
		savedCursor = Cursors.Arrow;
		//if (!busyCursor && !forceBusyCursor) Starter.frameworkElement.Cursor = Cursors.Arrow;
	}
	
	public static function setHandCursor() {
		savedCursor = Cursors.Hand;
		//if (!busyCursor && !forceBusyCursor) Starter.frameworkElement.Cursor = Cursors.Hand;
	}
	
	public static function setCursorBusy(busy: Bool) {
		/*busyCursor = busy;
		if (busy || forceBusyCursor) {
			Starter.frameworkElement.Cursor = Cursors.Wait;
		}
		else {
			Starter.frameworkElement.Cursor = savedCursor;
		}*/
	}
}
