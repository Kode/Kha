package kha.wpf;

import haxe.io.Bytes;
import kha.FontStyle;
import kha.Starter;
import system.io.File;
import system.windows.FrameworkElement;
import system.windows.input.Cursor;
import system.windows.input.Cursors;
import system.windows.input.Mouse;

class Loader extends kha.Loader {
	public static var path : String = "";
	public static var forceBusyCursor : Bool = false;
	var savedCursor : Cursor;
	var busyCursor : Bool = false;
	
	public override function loadProject(call: Void -> Void) {
		enqueue(new kha.Loader.Asset("project.kha", path + "project.kha", "blob"));
		loadFiles(call);
	}
	
	override function loadXml(filename : String) : Void {
		xmls.set(filename, Xml.parse(File.ReadAllText(path + filename)));
		--numberOfFiles;
		checkComplete();
	}

	override function loadMusic(filename : String) : Void {
		musics.set(filename, null);//new Music(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(filename : String) : Void {
		sounds.set(filename, new Sound(path + filename + ".wav"));
		--numberOfFiles;
		checkComplete();
	}

	override function loadImage(filename : String) : Void {
		images.set(filename, new Image(path + filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadBlob(filename :String): Void {
		blobs.set(filename, new Blob(Bytes.ofData(File.ReadAllBytes(filename))));
		--numberOfFiles;
		checkComplete();
	}

	override function loadVideo(filename : String) : Void {
		videos.set(filename, new Video(path + filename + ".wmv"));
		--numberOfFiles;
		checkComplete();
	}
	
	override public function loadFont(name : String, style : FontStyle, size : Int) : kha.Font {
		var font : kha.Font = new Font(name, style, size);
		return (font != null ? font : new Font("Arial", style, size));
	}

	@:functionBody('
		System.Diagnostics.Process.Start(new System.Uri(url).AbsoluteUri);
	')
	override public function loadURL(url : String) : Void {
		
	}

	override function checkComplete(): Void {
		if (numberOfFiles <= 0) {
			if (forceBusyCursor)
				Starter.frameworkElement.Cursor = Cursors.Wait;
		}
		super.checkComplete();
	}
	
	override function setNormalCursor() {
		savedCursor = Cursors.Arrow;
		if (!busyCursor && !forceBusyCursor) Starter.frameworkElement.Cursor = Cursors.Arrow;
	}
	
	override function setHandCursor() {
		savedCursor = Cursors.Hand;
		if (!busyCursor && !forceBusyCursor) Starter.frameworkElement.Cursor = Cursors.Hand;
	}
	
	override function setCursorBusy(busy : Bool) {
		busyCursor = busy;
		if (busy || forceBusyCursor)
			Starter.frameworkElement.Cursor = Cursors.Wait;
		else
			Starter.frameworkElement.Cursor = savedCursor;
	}
}