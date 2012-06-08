package kha.pss;

import haxe.io.Bytes;

class Loader extends kha.Loader {
	@:functionBody('
		var resourceStream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("PSTest.resources.data.xml");
		System.IO.StreamReader stream = new System.IO.StreamReader(resourceStream, System.Text.Encoding.GetEncoding("utf-8"));
		string xml = stream.ReadToEnd();
		stream.Close();
		xmls.set("data.xml", Xml.parse(xml));
		loadFiles();
	')
	override public function loadDataDefinition() : Void {
		
	}
	
	@:functionBody('
		var resourceStream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("PSTest.resources." + filename);
		System.IO.StreamReader stream = new System.IO.StreamReader(resourceStream, System.Text.Encoding.GetEncoding("utf-8"));
		string xml = stream.ReadToEnd();
		stream.Close();
		xmls.set("data.xml", Xml.parse(xml));
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
		var resourceStream = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream("PSTest.resources." + filename);
		System.IO.BinaryReader reader = new System.IO.BinaryReader(resourceStream);
		System.Collections.Generic.List<int> bytes = new System.Collections.Generic.List<int>();
		byte[] buffer = new byte[100];
		int bytesRead = 0;
		while ((bytesRead = resourceStream.Read(buffer, 0, 100)) > 0) {
			for (int i = 0; i < bytesRead; ++i) bytes.Add(buffer[i]);
		}	
		int[] bigBytes = new int[bytes.Count];
		bytes.CopyTo(bigBytes);
		for (int i = 0; i < bytes.Count; ++i) bigBytes[i] = bytes[i];
		blobs.set(filename, new Blob(new haxe.io.Bytes(bytes.Count, new haxe.root.Array<int>(bigBytes))));
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