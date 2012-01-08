package com.ktxsoftware.kha.backends.cpp;

import cpp.io.File;
import haxe.io.Bytes;

class Loader extends com.ktxsoftware.kha.Loader {
	var numberOfFiles : Int;
	
	public function new() {
		super();
	}
	
	private override function loadStarted(numberOfFiles : Int) {
		this.numberOfFiles = numberOfFiles;
	}
	
	public override function loadDataDefinition() {
		xmls.set("data.xml", Xml.parse(File.getContent("data.xml")));
		loadFiles();
	}
	
	override function loadXml(filename : String) {
		xmls.set(filename, Xml.parse(File.getContent(filename)));
		--numberOfFiles;
		checkComplete();
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
		images.set(filename, new com.ktxsoftware.kha.backends.cpp.Image(filename));
		--numberOfFiles;
		checkComplete();
	}
		
	var bytePosition : Int;
	
	function readInt(bytes : Bytes) : Int {
		var fourth = bytes.get(bytePosition + 0);
		var third  = bytes.get(bytePosition + 1);
		var second = bytes.get(bytePosition + 2);
		var first  = bytes.get(bytePosition + 3);
		bytePosition += 4;
		return first + second * 256 + third * 256 * 256 + fourth * 256 * 256 * 256;
	}
	
	override function loadMap(name : String) {
		bytePosition = 0;
		var bytes : Bytes = File.getBytes(name);
		var levelWidth : Int = readInt(bytes);
		var levelHeight : Int = readInt(bytes);
		var map : Array<Array<Int>> = new Array<Array<Int>>();
		for (x in 0...levelWidth) {
			map.push(new Array<Int>());
			for (y in 0...levelHeight) {
				map[x].push(readInt(bytes));
			}
		}
		maps.set(name, map);
		--numberOfFiles;
		checkComplete();
	}
	
	function checkComplete() {
		if (numberOfFiles <= 0) {
			Starter.loadFinished();
		}
	}
}