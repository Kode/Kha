package kha.js;

import js.Boot;
import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.ImageElement;
import kha.FontStyle;
import kha.Blob;
import kha.Kravur;
import kha.Starter;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Lib;
import js.html.XMLHttpRequest;

class Loader extends kha.Loader {
	public function new() {
		super();
	}
		
	override function loadMusic(desc: Dynamic, done: kha.Music -> Void) {
		if (Sys.audio != null) new WebAudioMusic(desc.file, done);
		else new Music(desc.file, done);
	}
	
	override function loadSound(desc: Dynamic, done: kha.Sound -> Void) {
		if (Sys.audio != null) new WebAudioSound(desc.file, done);
		else new Sound(desc.file, done);
	}
	
	override function loadImage(desc: Dynamic, done: kha.Image -> Void) {
		var img: ImageElement = cast Browser.document.createElement("img");
		img.src = desc.file;
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		img.onload = function(event: Dynamic) {
			done(Image.fromImage(img, readable));
		};
	}

	override function loadVideo(desc: Dynamic, done: kha.Video -> Void): Void {
		var video = new Video(desc.file, done);
	}
	
	override function loadBlob(desc: Dynamic, done: Blob -> Void) {
		var request = untyped new XMLHttpRequest();
		request.open("GET", desc.file, true);
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
				else Browser.alert("loadBlob failed");
				done(new Blob(bytes));
			}
			else Browser.alert("loadBlob failed");
		};
		request.send(null);
	}
	
	override public function loadFont(name: String, style: FontStyle, size: Float): kha.Font {
		if (Sys.gl != null) return Kravur.get(name, style, size);
		else return new Font(name, style, size);
	}

	override public function loadURL(url: String): Void {
		// inDAgo hack
		if (url.substr(0, 1) == '#')
			Browser.location.hash = url.substr(1, url.length - 1);
		else
			Browser.window.open(url, "Kha");
	}
	
	override public function setNormalCursor() {
		Mouse.SystemCursor = "default";
		Mouse.UpdateSystemCursor();
	}

	override public function setHandCursor() {
		Mouse.SystemCursor = "pointer";
		Mouse.UpdateSystemCursor();
	}
	
	override public function quit():Void 
	{
		// TODO: This will only work if the window has been opened by javascript in the first place.
		var window: js.html.DOMWindow = Browser.window;
		window.close();
	}
}
