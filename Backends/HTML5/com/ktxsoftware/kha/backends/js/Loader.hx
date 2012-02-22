package com.ktxsoftware.kha.backends.js;

import com.ktxsoftware.kha.Blob;
import com.ktxsoftware.kha.Starter;
import haxe.io.Bytes;
import haxe.io.BytesData;
import js.Dom;
import js.Lib;

class Loader extends com.ktxsoftware.kha.Loader {
	var numberOfFiles : Int;
	
	public function new() {
		super();
	}
	
	private override function loadStarted(numberOfFiles : Int) {
		this.numberOfFiles = numberOfFiles;
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
		var r = new haxe.Http(filename);
		r.onError = Lib.alert;
		r.onData = function(data : String) {
			blobs.set(filename, new Blob(Bytes.ofString(data)));
			--numberOfFiles;
			checkComplete();
		};
		r.request(false);
	}
	
	function checkComplete() {
		if (numberOfFiles <= 0) {
			//Lib.alert("Complete");
			Starter.loadFinished();
		}
	}
}