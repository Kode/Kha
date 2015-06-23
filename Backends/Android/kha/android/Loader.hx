package kha.android;

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

class Loader extends kha.Loader {
	var assetManager: AssetManager;
	
	public function new(context: Context) {
		super();
		this.assetManager = context.getAssets();
		Image.assets = assetManager;
	}
	
	override public function loadImage(desc: Dynamic, done: kha.Image->Void) {
		done(Image.createFromFile(desc.file));
	}

	override public function loadSound(desc: Dynamic, done: kha.Sound->Void) {
		var sound: kha.Sound = null;
		try {
			sound = new Sound(assetManager.openFd(desc.file + ".wav"));
		}
		catch (ex: IOException) {
			ex.printStackTrace();
		}
		done(sound);
	}

	override public function loadMusic(desc: Dynamic, done: kha.Music->Void) {
		var music: kha.Music = null;
		try {
			music = new Music(assetManager.openFd(desc.file + ".ogg"));
		}
		catch (ex: IOException) {
			ex.printStackTrace();
		}
		done(music);
	}
	
	override public function loadVideo(desc: Dynamic, done: kha.Video->Void) {
		var video: kha.Video = null;
		try {
			video = new Video(assetManager.openFd(desc.file + ".mp4"));
		}
		catch (ex: IOException) {
			ex.printStackTrace();
		}
		done(video);
	}
	
	override function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		return Kravur.get(name, style, size);
	}
	
	override public function loadBlob(desc: Dynamic, done: kha.Blob->Void): Void {
		var bytes: Array<Int> = new Array<Int>();
		try {
			var stream: java.io.InputStream = new java.io.BufferedInputStream(assetManager.open(desc.file));
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
}
