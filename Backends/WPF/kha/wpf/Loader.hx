package kha.wpf;

import kha.FontStyle;
import kha.Starter;
import system.io.File;
import system.windows.FrameworkElement;
import system.windows.input.Cursors;
import system.windows.input.Mouse;

class Loader extends kha.Loader {
	override public function loadDataDefinition() : Void {
		xmls.set("data.xml", Xml.parse(File.ReadAllText("data.xml")));
		loadFiles();
	}
	
	override function loadXml(filename : String) : Void {
		xmls.set(filename, Xml.parse(File.ReadAllText(filename)));
		--numberOfFiles;
		checkComplete();
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
	
	override function setNormalCursor() {
		Starter.frameworkElement.Cursor = Cursors.Arrow;
	}
	
	override function setHandCursor() {
		Starter.frameworkElement.Cursor = Cursors.Hand;
	}
}