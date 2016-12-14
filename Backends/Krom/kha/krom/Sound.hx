package kha.krom;

import haxe.ds.Vector;
import haxe.io.Bytes;

class Sound extends kha.Sound {

	public function new(bytes: Bytes) {
		super();
		compressedData = bytes;
		uncompressedData = null;
	}
	
	override public function uncompress(done: Void->Void): Void {
		if (uncompressedData != null) {
			done();
			return;
		}

		var soundBytes = compressedData;
		var count = Std.int(soundBytes.length / 4);
		uncompressedData = new Vector<Float>(count);
		for (i in 0...count) {
			uncompressedData[i] = soundBytes.getFloat(i * 4);
			//if (i < 10) Krom.log(" " + uncompressedData[i]);
		}
		
		compressedData = null;
		done();
	}

	override public function unload(): Void {
		super.unload();
	}
}
