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
		// TODO: simply call super class?
		if (uncompressedData != null) {
			done();
			return;
		}

		var soundBytes = compressedData;
		var count = Std.int(soundBytes.length / 4);
		if (false) {// TODO: if stereo
			uncompressedData = new Vector<Float>(count * 2);
			for (i in 0...count) {
				uncompressedData[i * 2 + 0] = soundBytes.getFloat(i * 4);
				uncompressedData[i * 2 + 1] = soundBytes.getFloat(i * 4);
			}
		}
		else {
			uncompressedData = new Vector<Float>(count);
			for (i in 0...count) {
				uncompressedData[i] = soundBytes.getFloat(i * 4);
				//if (i < 10 || i > soundBytes.length/4 - 10 ) Krom.log(i + " = " + uncompressedData[i]);
			}
		}
		compressedData = null;
		done();
	}

	override public function unload(): Void {
		super.unload();
	}
}
