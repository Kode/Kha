package kha;

import js.Browser;
import js.html.ImageElement;
import js.html.XMLHttpRequest;
import haxe.io.Bytes;
import kha.Blob;
import kha.js.WebAudioSound;
import kha.js.MobileWebAudioSound;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

using StringTools;

class LoaderImpl {
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void, failed: AssetError -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		if (StringTools.endsWith(desc.files[0], ".hdr")) {
			loadBlobFromDescription(desc, function(blob) {
				var hdrImage = kha.internal.HdrFormat.parse(blob.toBytes());
				done(Image.fromBytes(hdrImage.data.view.buffer, hdrImage.width, hdrImage.height, TextureFormat.RGBA128, readable ? Usage.DynamicUsage : Usage.StaticUsage));
			}, failed);
		}
		else {
			var img: ImageElement = cast Browser.document.createElement("img");
			img.onerror = function( event: Dynamic ) failed({ url: desc.files[0], error: event });
			img.onload = function(event: Dynamic) done(Image.fromImage(img, readable));
			img.src = desc.files[0];
			img.crossOrigin = "";
		}
	}

	public static function getSoundFormats(): Array<String> {
		var element = Browser.document.createAudioElement();
		var formats = new Array<String>();
		#if !kha_debug_html5
		if (element.canPlayType("audio/mp4") != "") formats.push("mp4");
		if (element.canPlayType("audio/mp3") != "") formats.push("mp3");
		#end
		if (SystemImpl._hasWebAudio || element.canPlayType("audio/ogg") != "") formats.push("ogg");
		return formats;
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void, failed: AssetError -> Void) {
		if (SystemImpl._hasWebAudio) {
			#if !kha_debug_html5
			var element = Browser.document.createAudioElement();
			if (element.canPlayType("audio/mp4") != "") {
				for (i in 0...desc.files.length) {
					var file: String = desc.files[i];
					if (file.endsWith(".mp4")) {
						new WebAudioSound(file, done, failed);
						return;
					}
				}
			}
			if (element.canPlayType("audio/mp3") != "") {
				for (i in 0...desc.files.length) {
					var file: String = desc.files[i];
					if (file.endsWith(".mp3")) {
						new WebAudioSound(file, done, failed);
						return;
					}
				}
			}
			#end
			for (i in 0...desc.files.length) {
				var file: String = desc.files[i];
				if (file.endsWith(".ogg")) {
					new WebAudioSound(file, done, failed);
					return;
				}
			}
		}
		else if (SystemImpl.mobile) {
			var element = Browser.document.createAudioElement();
			if (element.canPlayType("audio/mp4") != "") {
				for (i in 0...desc.files.length) {
					var file: String = desc.files[i];
					if (file.endsWith(".mp4")) {
						new MobileWebAudioSound(file, done, failed);
						return;
					}
				}
			}
			if (element.canPlayType("audio/mp3") != "") {
				for (i in 0...desc.files.length) {
					var file: String = desc.files[i];
					if (file.endsWith(".mp3")) {
						new MobileWebAudioSound(file, done, failed);
						return;
					}
				}
			}
			for (i in 0...desc.files.length) {
				var file: String = desc.files[i];
				if (file.endsWith(".ogg")) {
					new MobileWebAudioSound(file, done, failed);
					return;
				}
			}
		}
		else {
			new kha.js.Sound(desc.files, done, failed);
		}
	}

	public static function getVideoFormats(): Array<String> {
		#if kha_debug_html5
		return ["webm"];
		#else
		return ["mp4", "webm"];
		#end
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void, failed: AssetError -> Void): Void {
		kha.js.Video.fromFile(desc.files, done);
	}

	public static function loadRemote( desc: Dynamic, done: Blob -> Void, failed: AssetError -> Void ) {
		var request = untyped new XMLHttpRequest();
		request.open("GET", desc.files[0], true);
		request.responseType = "arraybuffer";

		request.onreadystatechange = function() {
			if (request.readyState != 4) return;
			if ((request.status >= 200 && request.status < 400) ||
				(request.status == 0 && request.statusText == '')) { // Blobs loaded using --allow-file-access-from-files
				var bytes: Bytes = null;
				var arrayBuffer = request.response;
				if (arrayBuffer != null) {
					var byteArray: Dynamic = untyped __js__("new Uint8Array(arrayBuffer)");
					bytes = Bytes.ofData(byteArray);
				}
				else if (request.responseBody != null) {
					var data: Dynamic = untyped __js__("VBArray(request.responseBody).toArray()");
					bytes = Bytes.alloc(data.length);
					for (i in 0...data.length) bytes.set(i, data[i]);
				}
				else {
					failed({ url: desc.files[0] });
					return;
				}

				done(new Blob(bytes));
			}
			else {
				failed({ url: desc.files[0] });
			}
		}
		request.send(null);
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void, failed: AssetError -> Void) {
#if kha_debug_html5
		var isUrl = desc.files[0].startsWith('http');

		if (isUrl) {
			loadRemote(desc, done, failed);
		}
		else {
			var fs = untyped __js__("require('electron').remote.require('fs')");
			var path = untyped __js__("require('electron').remote.require('path')");
			var app = untyped __js__("require('electron').remote.require('electron').app");
			var url = if (path.isAbsolute(desc.files[0])) desc.files[0] else path.join(app.getAppPath(), desc.files[0]);
			fs.readFile(url, function (err, data) {
				if (err != null) {
					failed({ url: url, error: err });
					return;
				}

				var byteArray: Dynamic = untyped __js__("new Uint8Array(data)");
				var bytes = Bytes.alloc(byteArray.byteLength);
				for (i in 0...byteArray.byteLength) bytes.set(i, byteArray[i]);
				done(new Blob(bytes));
			});
		}
#else
		loadRemote(desc, done, failed);
#end
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void, failed: AssetError -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Font(blob));
		}, failed);
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
