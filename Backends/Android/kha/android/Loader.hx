package kha.android;

import android.content.Context;
import android.content.res.AssetManager;
import haxe.io.Bytes;
import haxe.io.BytesData;
import java.io.Exceptions;
import java.lang.Number;
import java.lang.Object;
import java.NativeArray;
import kha.Blob;
import kha.FontStyle;

class Loader extends kha.Loader {
	var assetManager : AssetManager;
	
	public function new(context : Context) {
		super();
		this.assetManager = context.getAssets();
		Image.assets = assetManager;
	}
	
	override public function loadImage(filename : String) {
		images.set(filename, new Image(filename));
		--numberOfFiles;
		checkComplete();
	}

	override public function loadSound(filename : String) {
		try {
			sounds.set(filename, new Sound(assetManager.openFd(filename + ".wav")));
		}
		catch (ex : IOException) {
			ex.printStackTrace();
		}
		--numberOfFiles;
		checkComplete();
	}

	override public function loadMusic(filename : String) {
		try {
			musics.set(filename, new Music(assetManager.openFd(filename + ".ogg")));
		}
		catch (ex : IOException) {
			ex.printStackTrace();
		}
		--numberOfFiles;
		checkComplete();
	}
	
	override private function loadVideo(filename : String) {
		try {
			videos.set(filename, new Video(assetManager.openFd(filename + ".mp4")));
		}
		catch (ex : IOException) {
			ex.printStackTrace();
		}
		--numberOfFiles;
		checkComplete();
	}
	
	override public function loadFont(name : String, style : FontStyle, size : Int) : kha.Font {
		return new Font(name, style, size);
	}
	
	override private function loadBlob(filename : String) : Void {
		var bytes : Array<Byte> = new Array<Byte>();
		try {
			var stream : java.io.InputStream = new java.io.BufferedInputStream(assetManager.open(filename));
			var c : Int = -1;
			while ((c = stream.read()) != -1) {
				bytes.push(cast(c, Byte));
			}
			stream.close();
		}
		catch (ex : IOException) {
			
		}
		var array = new BytesData(bytes.length);
		for (i in 0...bytes.length) array[i] = bytes[i];
		var hbytes = Bytes.ofData(array);
		blobs.set(filename, new kha.Blob(hbytes));
		--numberOfFiles;
		checkComplete();
	}
	
	@:functionBody('
		
	')
	override function loadXml(filename : String) : Void {
		var everything : String = "";
		try {
			everything = new java.util.Scanner(assetManager.open(filename)).useDelimiter("\\A").next();
		}
		catch (e : java.util.NoSuchElementException) {
			return;
		}
		xmls.set(filename, Xml.parse(everything));
		--numberOfFiles;
		checkComplete();
	}
}