package kha.wpf;

import haxe.io.Bytes;
import haxe.Json;
import kha.FontStyle;
import kha.loader.Asset;
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
	
	public function new() {
		super();
		isQuitable = true;
	}
	
	public override function loadProject(call: Void -> Void) {
		enqueue(new kha.loader.Asset(path + "project.kha", path + "project.kha", "blob"));
		loadFiles(call);
	}
	
	private override function parseProject() : Dynamic {
		return Json.parse(getBlob(path + "project.kha").toString());
	}
	
	override function loadXml(asset: Asset) : Void {
		xmls.set(asset.name, Xml.parse(File.ReadAllText(path + asset.file)));
		--numberOfFiles;
		checkComplete();
	}

	override function loadMusic(asset: Asset) : Void {
		musics.set(asset.name, null);//new Music(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(asset: Asset) : Void {
		sounds.set(asset.name, new Sound(path + asset.file + ".wav"));
		--numberOfFiles;
		checkComplete();
	}

	override function loadImage(asset: Asset) : Void {
		images.set(asset.name, new Image(path + asset.file));
		--numberOfFiles;
		checkComplete();
	}

	override function loadBlob(asset: Asset): Void {
		blobs.set(asset.name, new Blob(Bytes.ofData(File.ReadAllBytes(asset.file))));
		--numberOfFiles;
		checkComplete();
	}

	override function loadVideo(asset: Asset) : Void {
		videos.set(asset.name, new Video(path + asset.file + ".wmv"));
		--numberOfFiles;
		checkComplete();
	}
	
	override public function loadFont(name : String, style : FontStyle, size : Int) : kha.Font {
		var font : kha.Font = new Font(name, style, size);
		return (font != null ? font : new Font("Arial", style, size));
	}

	@:functionCode('
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
	
	@:functionCode('
		System.Windows.Application.Current.Shutdown();
	')
	override function quit() : Void { }
}