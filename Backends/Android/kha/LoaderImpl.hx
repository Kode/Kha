package kha;

import android.content.Context;
import android.content.res.AssetManager;
import haxe.io.Bytes;
import haxe.io.BytesData;
import java.io.IOException;
import java.lang.Byte;
import java.lang.Number;
import java.lang.Object;
import java.NativeArray;
import kha.Blob;
import kha.FontStyle;
import kha.Kravur;

class LoaderImpl {
	private static var assetManager: AssetManager;
	
	public static function init(context: Context) {
		assetManager = context.getAssets();
		Image.assets = assetManager;
	}
	
	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image->Void) {
		done(Image.createFromFile(desc.files[0]));
	}
	
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg"];
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound->Void) {
		var sound: kha.Sound = null;
		try {
			sound = new kha.android.Sound(assetManager.openFd(desc.files[0]));
		}
		catch (ex: IOException) {
			ex.printStackTrace();
		}
		done(sound);
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["wav"];
	}

	/*public function loadMusicFromDescription(desc: Dynamic, done: kha.Music->Void) {
		var music: kha.Music = null;
		try {
			music = new Music(assetManager.openFd(desc.files[0]));
		}
		catch (ex: IOException) {
			ex.printStackTrace();
		}
		done(music);
	}*/
	
	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video->Void) {
		var video: kha.Video = null;
		try {
			video = new kha.android.Video(assetManager.openFd(desc.files[0]));
		}
		catch (ex: IOException) {
			ex.printStackTrace();
		}
		done(video);
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["ts"];
	}
	
	/*function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return Kravur.get(name, style, size);
	}*/
	
	public static function loadBlobFromDescription(desc: Dynamic, done: kha.Blob->Void): Void {
		var bytes: Array<Int> = new Array<Int>();
		try {
			var stream: java.io.InputStream = new java.io.BufferedInputStream(assetManager.open(desc.files[0]));
			var c: Int = -1;
			while ((c = stream.read()) != -1) {
				bytes.push(c);
			}
			stream.close();
		}
		catch (ex: IOException) {
			ex.printStackTrace();
		}
		var array = new BytesData(bytes.length);
		for (i in 0...bytes.length) array[i] = bytes[i];
		var hbytes = Bytes.ofData(array);
		done(new kha.Blob(hbytes));
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font->Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		});
	}
	
	/*override public function showKeyboard(): Void {
		Starter.showKeyboard = true;
	}
	
	override public function hideKeyboard(): Void {
		Starter.showKeyboard = false;
	}*/
}
