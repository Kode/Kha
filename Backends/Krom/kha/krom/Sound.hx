package kha.krom;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesData;
import kha.audio2.ogg.vorbis.Reader;

class Sound extends kha.Sound {

	public function new(bytes: Bytes) {
		super();
		compressedData = bytes;
		Krom.log("==== load ==== " + compressedData.length);
	}
	
	override public function uncompress(done: Void->Void): Void {
		// TODO
		var soundBytes = compressedData;
		var count = Std.int(soundBytes.length / 4);
		if (false) {
			uncompressedData = new Vector<Float>(count * 2);
			for (i in 0...count) {
				uncompressedData[i * 2 + 0] = soundBytes.get(i) / 255.0 * 2.0 - 1.0;
				uncompressedData[i * 2 + 1] = soundBytes.get(i) / 255.0 * 2.0 - 1.0;
			}
		}
		else {
			uncompressedData = new Vector<Float>(count);
			for (i in 0...count) {
				if (i < 12) Krom.log(i + " = " + (soundBytes.get(i)));// / 255.0 * 2.0 - 1.0));
				uncompressedData[i] = soundBytes.get(i) / 255.0 * 2.0 - 1.0;
			}
		}
		compressedData = null;
		done();
	}
	
	override public function unload(): Void {
		super.unload();
	}

	/*public function playSound(loop: Bool, stream: Bool) : Void {
		Krom.log("==== playSound ==== " + uncompressedData.length);
		Krom.playSound(uncompressedData, loop, stream);
	}*/
}
