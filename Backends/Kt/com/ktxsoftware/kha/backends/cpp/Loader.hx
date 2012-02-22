package com.ktxsoftware.kha.backends.cpp;

import com.ktxsoftware.kha.Blob;
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
	
	override function loadBlob(filename : String) {
		blobs.set(filename, new Blob(File.getBytes(filename)));
		--numberOfFiles;
		checkComplete();
	}
	
	function checkComplete() {
		if (numberOfFiles <= 0) {
			Starter.loadFinished();
		}
	}
}