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
		var sound = new Sound(filename, done);
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
		if (request.overrideMimeType != null) request.overrideMimeType('text/plain; charset=x-user-defined');
		else {
			request.setRequestHeader("Accept-Charset", "x-user-defined");
		}
		request.onreadystatechange = function() {
			if (request.readyState != 4) return;
			if (request.status >= 200 && request.status < 400) {
				var data : String = null;
				if (request.responseBody != null) {
					data = untyped __js__("arr(request.responseBody).replace(/[\\s\\S]/g, function(t){ var v= t.charCodeAt(0); return String.fromCharCode(v&0xff, v>>8); }) + arrl(request.responseBody)");
				}
				else {
					data = request.responseText;
				}
				var bytes = Bytes.alloc(data.length);
				for (i in 0...data.length) bytes.set(i, data.charCodeAt(i) & 0xff);
				done(new Blob(bytes));
			}
			else Lib.alert("loadBlob failed");
		};
		request.send(null);
	}
	
	override public function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		if (Sys.gl != null) return new Kravur(name, style, size);
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
