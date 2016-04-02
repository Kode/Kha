package kha;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

/**
 * Contains compressed or uncompressed audio data.
 */
class Sound implements Resource {
	public var compressedData: Bytes;
	public var uncompressedData: Vector<Float>;
	
	public function new() { }

	public function uncompress(done: Void->Void): Void {
		var output = new BytesOutput();
		var header = Reader.readAll(compressedData, output, true);
		var soundBytes = output.getBytes();
		var count = Std.int(soundBytes.length / 4);
		if (header.channel == 1) {
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
			}
		}
		compressedData = null;
		done();
	}

	public function unload() {
		compressedData = null;
		uncompressedData = null;
	}
}
