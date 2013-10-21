package kha.js;

import js.Boot;
import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.ImageElement;
import kha.FontStyle;
import kha.Blob;
import kha.Kravur;
import kha.Starter;
import kha.loader.Asset;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Lib;
import js.html.XMLHttpRequest;

class Loader extends kha.Loader {
	public function new() {
		super();
	}
		
	override function loadMusic(filename: String, done: kha.Music -> Void) {
		done(new Music(filename));
	}
	
	override function loadSound(filename: String, done: kha.Sound -> Void) {
		if (Sys.audio != null) new WebAudioSound(filename, done);
		else new Sound(filename, done);
	}
	
	override function loadImage(filename: String, done: kha.Image -> Void) {
		var img: ImageElement = cast Browser.document.createElement("img");
		img.src = filename;
		img.onload = function(event: Dynamic) {
			done(kha.js.Image.fromImage(img));
		};
	}

	override function loadVideo(filename: String, done: kha.Video -> Void): Void {
		var video = new Video(filename, done);
	}
	
	override function loadBlob(filename: String, done: Blob -> Void) {
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename, true);
		request.responseType = "arraybuffer";
		
		request.onreadystatechange = function() {
			if (request.readyState != 4) return;
			if (request.status >= 200 && request.status < 400) {
				var bytes: Bytes = null;
				var arrayBuffer = request.response;
				if (arrayBuffer != null) {
					var byteArray: Dynamic = untyped __js__("new Uint8Array(arrayBuffer)");
					bytes = Bytes.alloc(byteArray.byteLength);
					for (i in 0...byteArray.byteLength) bytes.set(i, byteArray[i]);
				}
				else if (request.responseBody != null) {
					var data: Dynamic = untyped __js__("VBArray(request.responseBody).toArray()");
					bytes = Bytes.alloc(data.length);
					for (i in 0...data.length) bytes.set(i, data[i]);
				}
				else Lib.alert("loadBlob failed");
				done(new Blob(bytes));
			}
			else Lib.alert("loadBlob failed");
		};
		request.send(null);
	}
	
	override public function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		if (Sys.gl != null) return Kravur.get(name, style, size);
		else return new Font(name, style, size);
	}

	override public function loadURL(url: String): Void {
		Browser.window.open(url, "Kha");
	}
	
	override public function setNormalCursor() {
		Browser.document.getElementById("khanvas").style.cursor = "default";
	}

	override public function setHandCursor() {
		Browser.document.getElementById("khanvas").style.cursor = "pointer";
	}
}
