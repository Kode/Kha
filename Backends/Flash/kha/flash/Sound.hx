package kha.flash;

import flash.media.SoundTransform;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

class Sound extends kha.Sound {
	public function new(bytes: Bytes) {
		super();
		var output = new BytesOutput();
		var header = Reader.readAll(bytes, output, true);
		var soundBytes = output.getBytes();
		var count = Std.int(soundBytes.length / 4);
		if (header.channel == 1) {
			data = new Vector<Float>(count * 2);
			for (i in 0...count) {
				data[i * 2 + 0] = soundBytes.getFloat(i * 4);
				data[i * 2 + 1] = soundBytes.getFloat(i * 4);
			}
		}
		else {
			data = new Vector<Float>(count);
			for (i in 0...count) {
				data[i] = soundBytes.getFloat(i * 4);
			}
		}
	}
}
