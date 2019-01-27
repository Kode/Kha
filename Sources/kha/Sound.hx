package kha;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

/**
 * Contains compressed or uncompressed audio data.
 */
class Sound implements Resource {
	public var compressedData: Bytes;
	public var uncompressedData: kha.arrays.Float32Array;
	public var length: Float = 0; // in seconds
	
	public function new() {
		
	}

	public function uncompress(done: Void->Void): Void {
		#if (!kha_no_ogg)
		if (uncompressedData != null) {
			done();
			return;
		}
		
		var output = new BytesOutput();
		var header = Reader.readAll(compressedData, output, true);
		var soundBytes = output.getBytes();
		var count = Std.int(soundBytes.length / 4);
		if (header.channel == 1) {
			length = count / kha.audio2.Audio.samplesPerSecond;// header.sampleRate;
			uncompressedData = new kha.arrays.Float32Array(count * 2);
			for (i in 0...count) {
				uncompressedData[i * 2 + 0] = soundBytes.getFloat(i * 4);
				uncompressedData[i * 2 + 1] = soundBytes.getFloat(i * 4);
			}
		}
		else {
			length = count / 2 / kha.audio2.Audio.samplesPerSecond; //header.sampleRate;
			uncompressedData = new kha.arrays.Float32Array(count);
			for (i in 0...count) {
				uncompressedData[i] = soundBytes.getFloat(i * 4);
			}
		}
		compressedData = null;
		done();
		#end
	}

	public function unload() {
		compressedData = null;
		uncompressedData = null;
	}
}
