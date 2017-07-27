package kha.android;

import android.media.SoundPool;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import haxe.Int64;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import java.NativeArray;
import kha.audio1.AudioChannel;

class Sound extends kha.Sound {
	//static var pool : SoundPool = new SoundPool(4, AudioManager.STREAM_MUSIC, 0);
	//var soundid : Int;
	// var wavBytes: NativeArray<java.types.Int8>;
	
	public function new(file : AssetFileDescriptor) {
		super();
		//soundid = pool.load(file, 1);
		var inputStream = file.createInputStream();
		inputStream.skip(44); // assume wave header has 44 bytes (can fail, should parse header instead)
		var length = inputStream.available();
		var wavBytes = new NativeArray<java.types.Int8>(length);
		inputStream.read(wavBytes);
		inputStream.close();
		compressedData = Bytes.ofData(wavBytes);
		wavBytes = null;
	}
	
	//public function play(): AudioChannel {
		//pool.play(soundid, 1, 1, 1, 0, 1);
		//return null;
	//}

	public override function uncompress(done:Void->Void): Void {
		var numFrames:Int = Math.floor(compressedData.length / 4);
		uncompressedData = new haxe.ds.Vector<Float>(numFrames * 2);
		// assume stereo channels
		for (i in 0...numFrames) {
			uncompressedData[2 * i + 0] = (compressedData.getUInt16(4 * i + 0) - 32768) / 32768; // signed Int16 in little endian to Float in range [-1, 1)
			uncompressedData[2 * i + 1] = (compressedData.getUInt16(4 * i + 2) - 32768) / 32768;
		}
		compressedData = null;
		done();
	}
	
	//override public function uncompress(done:Void->Void):Void 
	//{
		//var timeInSec:Float = 10;
		//var rate = 44100;
		//var numFrames = Math.floor(timeInSec * rate);
		//uncompressedData = new haxe.ds.Vector<Float>(numFrames * 2);
		//var soundFreq = 130.81; // C3
		//
		//var time:Float = 0;
		//for (i in 0...numFrames) {
			//uncompressedData[2 * i + 0] = Math.sin(time * soundFreq);
			//uncompressedData[2 * i + 1] = Math.sin(time * soundFreq);
			//time += 1 / rate;
		//}
		//
		//compressedData = null;
		//done();
	//}
	
	//override public function stop() : Void {
	//	pool.stop(soundid);
	//}
}