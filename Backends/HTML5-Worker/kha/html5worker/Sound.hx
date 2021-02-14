package kha.html5worker;

import haxe.io.Bytes;
import haxe.ds.Vector;

class Sound extends kha.Sound {
	public var _id: Int;
	public var _callback: Void->Void;

	public function new(id: Int) {
		super();
		this._id = id;
	}

	override public function uncompress(done: Void->Void): Void {
		compressedData = null;
		Worker.postMessage({command: 'uncompressSound', id: _id});
		_callback = done;
	}

	override public function unload() {
		compressedData = null;
		uncompressedData = null;
	}
}
