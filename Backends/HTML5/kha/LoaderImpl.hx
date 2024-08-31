package kha;

import haxe.io.Bytes;
import js.Browser;
import js.Syntax;
import js.html.FileReader;
import js.html.ImageElement;
import js.html.XMLHttpRequest;
import kha.Blob;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.js.MobileWebAudioSound;
import kha.js.WebAudioSound;

using StringTools;

class LoaderImpl {
	@:allow(kha.SystemImpl)
	static var dropFiles = new Map<String, js.html.File>();

	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image->Void, failed: (err: AssetError) -> Void) {
		var readable = Reflect.hasField(desc, "readable") ? desc.readable : false;
		if (StringTools.endsWith(desc.files[0], ".hdr")) {
			loadBlobFromDescription(desc, function(blob) {
				var hdrImage = kha.internal.HdrFormat.parse(blob.toBytes());
				done(Image.fromBytes(hdrImage.data.view.buffer, hdrImage.width, hdrImage.height, TextureFormat.RGBA128,
					readable ? Usage.DynamicUsage : Usage.StaticUsage));
			}, failed);
		}
		else {
			var img: ImageElement = cast Browser.document.createElement("img");
			img.onerror = function(event: Dynamic) failed({url: desc.files[0], error: event});
			img.onload = function(event: Dynamic) done(Image.fromImage(img, readable));
			img.crossOrigin = "";
			img.src = desc.files[0];
		}
	}

	public static function getSoundFormats(): Array<String> {
		var element = Browser.document.createAudioElement();
		var formats = new Array<String>();
		#if !kha_debug_html5
		if (element.canPlayType("audio/mp4") != "")
			formats.push("mp4");
		if (element.canPlayType("audio/mp3") != "")
			formats.push("mp3");
		if (element.canPlayType("audio/wav") != "")
			formats.push("wav");
		#end
		if (SystemImpl._hasWebAudio || element.canPlayType("audio/ogg") != "")
			formats.push("ogg");
		return formats;
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound->Void, failed: (err: AssetError) -> Void) {
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
			if (element.canPlayType("audio/wav") != "") {
				for (i in 0...desc.files.length) {
					var file: String = desc.files[i];
					if (file.endsWith(".wav")) {
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
			failed({
				url: desc.files.join(","),
				error: "Unable to find sound files with supported audio formats",
			});
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
			if (element.canPlayType("audio/wav") != "") {
				for (i in 0...desc.files.length) {
					var file: String = desc.files[i];
					if (file.endsWith(".wav")) {
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
			failed({
				url: desc.files.join(","),
				error: "Unable to find sound files with supported audio formats",
			});
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

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video->Void, failed: (err: AssetError) -> Void): Void {
		kha.js.Video.fromFile(desc.files, done);
	}

	public static function loadRemote(desc: Dynamic, done: Blob->Void, failed: (err: AssetError) -> Void) {
		var request = untyped new XMLHttpRequest();
		request.open("GET", desc.files[0], true);
		request.responseType = "arraybuffer";

		request.onreadystatechange = function() {
			if (request.readyState != 4)
				return;
			if ((request.status >= 200 && request.status < 400)
				|| (request.status == 0 && request.statusText == "")) { // Blobs loaded using --allow-file-access-from-files
				var bytes: Bytes = null;
				var arrayBuffer = request.response;
				if (arrayBuffer != null) {
					var byteArray: Dynamic = Syntax.code("new Uint8Array(arrayBuffer)");
					bytes = Bytes.ofData(byteArray);
				}
				else if (request.responseBody != null) {
					var data: Dynamic = untyped Syntax.code("VBArray(request.responseBody).toArray()");
					bytes = Bytes.alloc(data.length);
					for (i in 0...data.length)
						bytes.set(i, data[i]);
				}
				else {
					failed({url: desc.files[0]});
					return;
				}

				done(new Blob(bytes));
			}
			else {
				failed({url: desc.files[0]});
			}
		}
		request.send(null);
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob->Void, failed: (err: AssetError) -> Void) {
		#if kha_debug_html5
		var file: String = desc.files[0];

		if (file.startsWith("http://") || file.startsWith("https://")) {
			loadRemote(desc, done, failed);
		}
		else if (file.startsWith("drop://")) {
			var dropFile = dropFiles.get(file.substring(7));
			if (dropFile == null)
				failed({url: file, error: 'file not found'});
			else {
				var reader = new FileReader();
				reader.onloadend = () -> {
					done(new Blob(Bytes.ofData(reader.result)));
				};
				reader.onerror = () -> failed({url: file, error: reader.error});
				reader.readAsArrayBuffer(dropFile);
			}
		}
		else {
			var loadBlob = Syntax.code("window.electron.loadBlob");
			loadBlob(desc, (byteArray: Dynamic) -> {
				var bytes = Bytes.alloc(byteArray.byteLength);
				for (i in 0...byteArray.byteLength)
					bytes.set(i, byteArray[i]);
				done(new Blob(bytes));
			}, failed);
		}
		#else
		loadRemote(desc, done, failed);
		#end
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font->Void, failed: (err: AssetError) -> Void): Void {
		loadBlobFromDescription(desc, function(blob: Blob) {
			done(new Font(blob));
		}, failed);
	}
}
