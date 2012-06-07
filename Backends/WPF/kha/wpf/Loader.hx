package kha.wpf;

import kha.FontStyle;

class Loader extends kha.Loader {
	@:functionBody('
		xmls.set("data.xml", Xml.parse(System.IO.File.ReadAllText("data.xml")));
		loadFiles();
	')
	override public function loadDataDefinition() : Void {
		
	}
	
	@:functionBody('
		xmls.set(filename, Xml.parse(System.IO.File.ReadAllText(filename)));
		--numberOfFiles;
		checkComplete();
	')
	override function loadXml(filename : String) : Void {
		
	}

	override function loadMusic(filename : String) : Void {
		musics.set(filename, null);//new Music(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(filename : String) : Void {
		sounds.set(filename, null);//new Sound(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadImage(filename : String) : Void {
		images.set(filename, new Image(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadBlob(filename : String) : Void {
		blobs.set(filename, null);//new Blob(File.getBytes(filename)));
		--numberOfFiles;
		checkComplete();
	}

	override public function loadFont(name : String, style : FontStyle, size : Int) : kha.Font {
		return new Font(name, style, size);
	}

	function checkComplete() : Void {
		if (numberOfFiles <= 0) {
			kha.Starter.loadFinished();
		}
	}
}