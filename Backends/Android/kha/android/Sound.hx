package kha.android;

import android.content.res.AssetFileDescriptor;
import android.media.MediaExtractor;
import android.media.MediaFormat;
import android.media.MediaPlayer;
import android.media.SoundPool;
import android.media.SoundPoolOnLoadCompleteListener;
import android.os.BuildVERSION;
import kha.audio1.Audio;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Condition;
import kha.audio1.MediaPlayerChannel;
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
	@:noCompletion
	public var soundId(default, null) = -1;
	@:noCompletion
	public var mediaPlayer(default, null): MediaPlayer = null;
	//public var length(default, null): Float = 0;
	@:noCompletion
	public var ownedByMPC: MediaPlayerChannel;
	
	public function new(file: AssetFileDescriptor) {
		super();
		
		var uncompressedSize: Float;
		var sampleRate = 48000; // worst case
		var channelCount = 2;
		
		// if api >= 16 determine sample rate and channel count for size calculation
		if (BuildVERSION.SDK_INT >= 16) {
			try {
				var mex = new MediaExtractor();
				mex.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
				var mf = mex.getTrackFormat(0);
				sampleRate = mf.getInteger(MediaFormat.KEY_SAMPLE_RATE);
				channelCount = mf.getInteger(MediaFormat.KEY_CHANNEL_COUNT);
				mex.release();
			}
			catch (e: Dynamic) {
				trace(e);
			}
		}
		
		try {
			mediaPlayer = new MediaPlayer();
			mediaPlayer.setDataSource(file.getFileDescriptor(), file.getStartOffset(), file.getLength());
			mediaPlayer.prepare();
			length = mediaPlayer.getDuration() / 1000; // getDuration returns milliseconds
			channels = channelCount;
		}
		catch (e: Dynamic) {
			trace(e);
		}
		
		uncompressedSize = (length != 0) ? sampleRate * channelCount * length * 2 : 1024 * 1024 + 1;
		if (uncompressedSize < 1024 * 1024 && Audio.spSamples < Audio.spSamplesMax) {
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
					Audio.spSamples++;
				}
				lock.unlock();
			}
			catch (e: Dynamic) {
				trace(e);
			}
		}
		if (soundId > 0) {
			mediaPlayer.release();
			mediaPlayer = null;
		}
	}
	
	override public function uncompress(done: Void->Void): Void {
		done();
	}
	
	override public function unload(): Void {
		if (soundId > 0) {
			if (Audio.soundpool.unload(soundId)) {
				Audio.spSamples--;
			}
		}
		if (mediaPlayer != null) {
			mediaPlayer.release();
		}
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