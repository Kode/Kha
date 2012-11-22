package kha.js;

import kha.FontStyle;
import kha.Blob;
import kha.Starter;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Dom;
import js.Lib;
import js.XMLHttpRequest;

class Loader extends kha.Loader {
	public function new() {
		super();
	}
		
	override function loadXml(filename: String) {
		var r = new haxe.Http(filename);
		r.onError = function(error:String) {
			Lib.alert("Error loading " + filename + ": " + error);
		}
		r.onData = function(data : String) {
			xmls.set(filename, Xml.parse(data));
			--numberOfFiles;
			checkComplete();
		};
		r.request(false);
	}
	
	override function loadMusic(filename: String) {
		musics.set(filename, new Music(filename));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadSound(filename: String) {
		//trace ("loadSound " + filename);
		var sound = new Sound(filename);
		//sound.element.onloadstart = trace ("onloadstart( " + element.src + " )");
		sounds.set(filename, sound);
		sound.element.oncanplaythrough = function () {
				//trace ("loaded " + sound.element.src);
				sound.element.oncanplaythrough = null;
				--numberOfFiles;
				checkComplete();
			};
	}
	
	override function loadImage(filename: String) {
		var img : js.Image = cast Lib.document.createElement("img");
		img.src = filename;
		img.onload = function(event : Event) {
			images.set(filename, new kha.js.Image(img));
			--numberOfFiles;
			checkComplete();
		};
	}
	
	override function loadVideo(filename: String): Void {
		videos.set(filename, new Video(filename));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadBlob(filename: String) {
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
				blobs.set(filename, new Blob(bytes));
				--numberOfFiles;
				checkComplete();
			}
			else Lib.alert("loadBlob failed");
		};
		request.send(null);
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