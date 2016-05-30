package kha;

import js.Boot;
import js.Browser;
import js.html.audio.DynamicsCompressorNode;
import js.html.ImageElement;
import js.Lib;
import js.html.XMLHttpRequest;
import haxe.io.Bytes;
import haxe.io.BytesData;
import kha.FontStyle;
import kha.Blob;
import kha.js.WebAudioSound;
import kha.Kravur;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

using StringTools;

class LoaderImpl {
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}
	
	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		if (StringTools.endsWith(desc.files[0], ".hdr")) {
			loadBlobFromDescription(desc, function(blob) {
				var hdrImage = kha.internal.HdrFormat.parse(blob.toBytes());
				done(Image.fromBytes(hdrImage.data.view.buffer, hdrImage.width, hdrImage.height, TextureFormat.RGBA128, readable ? Usage.DynamicUsage : Usage.StaticUsage));
			});
		}
		else {
			var img: ImageElement = cast Browser.document.createElement("img");
			img.src = desc.files[0];
			img.onload = function(event: Dynamic) {
				done(Image.fromImage(img, readable));
			};
		}
	}
	
	public static function getSoundFormats(): Array<String> {
		var element = Browser.document.createAudioElement();
		var formats = new Array<String>();
		if (element.canPlayType("audio/mp4") != "") formats.push("mp4");
		if (SystemImpl._hasWebAudio || element.canPlayType("audio/ogg") != "") formats.push("ogg");
		return formats;
	}
	
	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void) {
		if (SystemImpl._hasWebAudio) {
			var element = Browser.document.createAudioElement();
			if (element.canPlayType("audio/mp4") != "") {
				for (i in 0...desc.files.length) {
					var file: String = desc.files[i];
					if (file.endsWith(".mp4")) {
						new WebAudioSound(file, done);
						return;
					}
				}
			}
			for (i in 0...desc.files.length) {
				var file: String = desc.files[i];
				if (file.endsWith(".ogg")) {
					new WebAudioSound(file, done);
					return;
				}
			}
		}
		else new kha.js.Sound(desc.files, done);
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["mp4", "webm"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void): Void {
		var video = new kha.js.Video(desc.files, done);
	}
    
	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void) {
		#if sys_debug_html5
		var fs = untyped __js__("require('fs')");
        var path = untyped __js__("require('path')");
        var app = untyped __js__("require('remote').require('app')");
        fs.readFile(path.join(app.getAppPath(), desc.files[0]), function (err, data) {
			var byteArray: Dynamic = untyped __js__("new Uint8Array(data)");
            var bytes = Bytes.alloc(byteArray.byteLength);
            for (i in 0...byteArray.byteLength) bytes.set(i, byteArray[i]);
            done(new Blob(bytes));
		});
		#else
		var request = untyped new XMLHttpRequest();
		request.open("GET", desc.files[0], true);
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
				else {
					trace("Error loading " + desc.files[0]);
					Browser.console.log("loadBlob failed");
				}
				done(new Blob(bytes));
			}
			else {
				trace("Error loading " + desc.files[0]);
				Browser.console.log("loadBlob failed");
			}
		};
		request.send(null);
		#end
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			if (SystemImpl.gl == null) done(new kha.js.Font(new Kravur(blob)));
			else done(new Kravur(blob));
		});
	}
	
	/*override public function loadURL(url: String): Void {
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
	}*/
}
