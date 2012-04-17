package com.ktxsoftware.kha.backends.js;
import com.ktxsoftware.kha.FontStyle;

import com.ktxsoftware.kha.Blob;
import com.ktxsoftware.kha.Starter;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Dom;
import js.Lib;
import js.XMLHttpRequest;

class Loader extends com.ktxsoftware.kha.Loader {
	public function new() {
		super();
	}
	
	public override function loadDataDefinition() {
		var r = new haxe.Http("data.xml");
		r.onError = Lib.alert;
		r.onData = function(data : String) {
			xmls.set("data.xml", Xml.parse(data));
			loadFiles();
		};
		r.request(false);
	}
	
	override function loadXml(filename : String) {
		var r = new haxe.Http(filename);
		r.onError = Lib.alert;
		r.onData = function(data : String) {
			xmls.set(filename, Xml.parse(data));
			--numberOfFiles;
			checkComplete();
		};
		r.request(false);
	}
	
	override function loadMusic(filename : String) {
		musics.set(filename, new Music(filename));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadSound(filename : String) {
		sounds.set(filename, new Sound(filename));
		--numberOfFiles;
		checkComplete();
	}
	
	override function loadImage(filename : String) {
		var img : js.Image = cast Lib.document.createElement("img");
		img.src = filename;
		img.onload = function(event : Event) {
			images.set(filename, new com.ktxsoftware.kha.backends.js.Image(img));
			--numberOfFiles;
			checkComplete();
		};
	}
	
	override function loadBlob(filename : String) {
		var request = untyped new XMLHttpRequest();
		request.overrideMimeType('text/plain; charset=x-user-defined');
		request.open("GET", filename, true);
		request.onreadystatechange = function() {
			if (request.readyState != 4) return;
			if (request.status >= 200 && request.status < 400) {
				var data : String = request.responseText;
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
	
	override public function loadFont(name : String, style : FontStyle, size : Int) : com.ktxsoftware.kha.Font {
		return new Font(name, style, size);
	}
	
	function checkComplete() {
		if (numberOfFiles <= 0) {
			//Lib.alert("Complete");
			Starter.loadFinished();
		}
	}
}