package kha.js;

import js.Boot;
import kha.FontStyle;
import kha.Blob;
import kha.Starter;
import kha.loader.Asset;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Dom;
import js.Lib;
import js.XMLHttpRequest;

class Loader extends kha.Loader {
	public function new() {
		super();
	}
		
	override function loadXml(asset: Asset) {
		var r = new haxe.Http(asset.file);
		r.onError = function(error:String) {
			Lib.alert("Error loading " + asset.file + ": " + error);
		}
		r.onData = function(data : String) {
			xmls.set(asset.name, Xml.parse(data));
			--numberOfFiles;
			checkComplete();
		};
		r.request(false);
	}
	
	override function loadMusic(asset: Asset) {
		musics.set(asset.name, new Music(asset.file));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadSound(asset: Asset) {
		/*//trace ("loadSound " + filename);
		var sound = new Sound(asset.file);
		//sound.element.onloadstart = trace ("onloadstart( " + element.src + " )");
		sound.element.onerror = function(ex: Dynamic) {
			Lib.alert("Error loading " + sound.element.src);
		}
		sound.element.oncanplaythrough = function () {
			//trace ("loaded " + sound.element.src);
			sound.element.oncanplaythrough = null;
			--numberOfFiles;
			checkComplete();
		};
		sounds.set(asset.name, sound);*/
		
		sounds.set(asset.name, new Sound(asset.file));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadImage(asset: Asset) {
		var img : js.Image = cast Lib.document.createElement("img");
		img.src = asset.file;
		img.onload = function(event : Event) {
			images.set(asset.name, new kha.js.Image(img));
			--numberOfFiles;
			checkComplete();
		};
	}
	
	override function loadVideo(asset: Asset): Void {
		//trace ("loadVideo( " + filename + " )");
		var video = new Video(asset.file);
		//video.element.onloadstart = trace ("onloadstart( " + video.element.src + " )");
		video.element.onerror = function(ex : Dynamic) {
			Lib.alert("Error loading " + video.element.src);
		}
		video.element.oncanplaythrough = function () {
			//trace ("loaded " + video.element.src);
			video.element.oncanplaythrough = null;
			--numberOfFiles;
			checkComplete();
		};
		videos.set(asset.name, video);
	}
	
	override function loadBlob(asset : Asset) {
		var request = untyped new XMLHttpRequest();
		request.open("GET", asset.file, true);
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
				blobs.set(asset.name, new Blob(bytes));
				--numberOfFiles;
				checkComplete();
			}
			else Lib.alert("loadBlob failed");
		};
		request.send(null);
	}
	
	override public function getShader(name: String): Blob {
		return getBlob(name + ".glsl.essl");
	}
	
	override public function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		return new Font(name, style, size);
	}
	
	override public function setNormalCursor() {
		Lib.document.getElementById("haxvas").style.cursor = "default";
	}

	override public function setHandCursor() {
		Lib.document.getElementById("haxvas").style.cursor = "pointer";
	}
}