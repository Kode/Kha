package kha.xna;
import haxe.io.Bytes;

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
		musics.set(filename, new Music(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(filename : String) : Void {
		sounds.set(filename, new Sound(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadImage(filename : String) : Void {
		images.set(filename, new Image(filename));
		--numberOfFiles;
		checkComplete();
	}

	@:functionBody('
		byte[] bytes = System.IO.File.ReadAllBytes(filename);
		int[] bigBytes = new int[bytes.Length];
		for (int i = 0; i < bytes.Length; ++i) bigBytes[i] = bytes[i];
		blobs.set(filename, new Blob(new haxe.io.Bytes(bytes.Length, new haxe.root.Array<int>(bigBytes))));
		--numberOfFiles;
		checkComplete();
	')
	override function loadBlob(filename : String) : Void {
		
	}

	override public function loadFont(name : String, style : FontStyle, size : Int) : kha.Font {
		return null; //new Font(name, style, size);
	}

	function checkComplete() : Void {
		if (numberOfFiles <= 0) {
			kha.Starter.loadFinished();
		}
	}
}