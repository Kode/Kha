package kha.krom;

import haxe.io.Bytes;

class Sound extends kha.Sound {
	public function new(bytes: Bytes) {
		super();

		var count = Std.int(bytes.length / 4);
		uncompressedData = new kha.arrays.Float32Array(count);
		for (i in 0...count) {
			uncompressedData[i] = bytes.getFloat(i * 4);
		}
		
		compressedData = null;
	}
	
	override public function uncompress(done: Void->Void): Void {
		done();
	}

	override public function unload(): Void {
		super.unload();
	}
}
