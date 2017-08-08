package kha.android;

import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.media.SoundPoolOnLoadCompleteListener;
import kha.audio1.Audio;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
//import haxe.io.Bytes;
//import java.NativeArray;
//import java.types.Int8;
//import java.io.FileInputStream;

class LoadListener implements SoundPoolOnLoadCompleteListener {
	private var lock: ReentrantLock;
	private var condition: Condition;
	public var status(default, null): Int;
	
	public function new(lock: ReentrantLock, condition: Condition): Void {
		this.lock = lock;
		this.condition = condition;
	}
	
	public function onLoadComplete(soundPool: SoundPool, soundId: Int, status:Int): Void {
		lock.lock();
		this.status = status;
		condition.signal();
		lock.unlock();
	}
}

class Sound extends kha.Sound {
	private var afd: AssetFileDescriptor;
	public var soundId(default, null) = -1;
	public var mediaPlayer(default, null): MediaPlayer = null;
	
	public function new(file: AssetFileDescriptor) {
		super();
		if (file.getLength() < 1024 * 1024) { // does only guarantee complete playback for wav/flac (audio signal may be bigger than 1MB after decompression)
			try {
				var id:Int = Audio.soundpool.load(file, 1);
				var lock = new ReentrantLock();
				var isLoaded = lock.newCondition();
				var ll = new LoadListener(lock, isLoaded);
				Audio.soundpool.setOnLoadCompleteListener(ll);
				lock.lock();
				isLoaded.await();
				if (id > 0 && ll.status == 0) {
					this.soundId = id;
				}
				lock.unlock();
			}
			catch (e: Dynamic) {
				trace(e);
			}
		}
		if (soundId < 0) {
			try {
				mediaPlayer = new MediaPlayer();
				mediaPlayer.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
				mediaPlayer.prepare();
			}
			catch (e: Dynamic) {
				trace(e);
			}
		}
	}
	
	override public function uncompress(done: Void->Void): Void {
		done();
	}
	
	//public function new(file : AssetFileDescriptor) {
		//super();
		//try {
			//var inputStream = file.createInputStream();
			//parseWaveFile(inputStream);
		//}
		//catch (msg:String) {
			//trace("Error occured while parsing WAV file: " + msg);
		//}
		//catch (e:Dynamic) {
			//trace(e);
		//}
	//}
	
	//private function parseWaveFile(input:FileInputStream): Void {
		//var wavBytes = new NativeArray<Int8>(input.available());
		//input.read(wavBytes);
		//input.close();
		//var data = Bytes.ofData(wavBytes);
		//wavBytes = null;
		//// read header
		//if (data.getString(0, 4) != "RIFF" || data.getString(8, 4) != "WAVE") {
			//throw "File is not little-endian encoded.";
		//}
		//if (data.getUInt16(20) != 1 || data.getUInt16(34) != 16) {
			//throw "File is not 16 bit PCM encoded.";
		//}
		//if (data.getUInt16(22) != 2) {
			//throw "Audio is not sampled in stereo.";
		//}
		//var testRate:Int = data.getInt32(24);
		//// testRate is 48000 in release mode despite the value of 44100 in files.
		//// In debug mode 44100 is read...
		////if (44100 != compRate) {
			////throw "Audio is not sampled at 44.100 kHz.";
		////}
		//var nextSubchunk = 20 + data.getInt32(16);
		//var chunkSize = 0;
		//while (data.getString(nextSubchunk, 4) != "data") {
			//chunkSize = data.getInt32(nextSubchunk + 4);
			//nextSubchunk = nextSubchunk + 8 + chunkSize;
			//if (nextSubchunk + 8 > data.length) {
				//throw "No data chunk found.";
			//}
		//}
		//chunkSize = data.getInt32(nextSubchunk + 4);
		//
		//compressedData = data.sub(nextSubchunk + 8, chunkSize);
		//data = null;
	//}
	//
	//public override function uncompress(done:Void->Void): Void {
		//var numFrames:Int = Math.floor(compressedData.length / 4);
		//uncompressedData = new haxe.ds.Vector<Float>(numFrames * 2);
		//// assume stereo channels
		//for (i in 0...numFrames) {
			//// signed Int16 in little endian to Float in range [-1, 1)
			//uncompressedData[2 * i + 0] = uint16ToInt16(compressedData.getUInt16(4 * i + 0)) / 32768;
			//uncompressedData[2 * i + 1] = uint16ToInt16(compressedData.getUInt16(4 * i + 2)) / 32768;
		//}
		//compressedData = null;
		//done();
	//}
	//
	//private inline function uint16ToInt16(uint:Int): Int {
		//return (uint + 32768) % 65536 - 32768;
	//}
}