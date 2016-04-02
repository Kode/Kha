package kha.flash;

import flash.media.SoundTransform;
import flash.utils.ByteArray;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

class Sound extends kha.Sound {
	@:noCompletion
	public var _mp3format: Bool;
	@:noCompletion
	public var _mp3: flash.media.Sound;
	
	public function new(bytes: Bytes) {
		super();
		compressedData = bytes;
		_mp3 = null;
	}
	
	@:noCompletion
	public function _prepareMp3(): Bool {
		if (_mp3 == null) {
			_mp3 = new flash.media.Sound();
			_mp3.loadCompressedDataFromByteArray(compressedData.getData(), compressedData.length);
		}
		return _mp3format;
	}
	
	override public function uncompress(done: Void->Void): Void {
		if (uncompressedData != null) {
			done();
			return;
		}
		
		if (_mp3format) {
			_prepareMp3();
			var length = 44100 * _mp3.length;
			var array = new ByteArray();
			var extractedLength: Int = cast (_mp3.extract(array, length));
			uncompressedData = new Vector<Float>(extractedLength);
			array.position = 0;
			for (i in 0...extractedLength) {
				uncompressedData.set(i, array.readFloat());
			}
			_mp3 = null;
			compressedData = null;
			done();
		}
		else {
			super.uncompress(done);
		}
	}
	
	override public function unload(): Void {
		super.unload();
		_mp3 = null;
	}
}
