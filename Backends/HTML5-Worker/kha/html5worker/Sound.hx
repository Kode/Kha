package kha.html5worker;

import haxe.io.Bytes;
import haxe.ds.Vector;

class Sound extends kha.Sound {
	public function new() {
		super();
	}

	override public function uncompress(done: Void->Void): Void {
		compressedData = null;
		done();
	}

	override public function unload() {
		compressedData = null;
		uncompressedData = null;
	}
}
