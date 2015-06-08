package kha.flash;

import flash.media.SoundTransform;
import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BytesOutput;
import kha.audio2.ogg.vorbis.Reader;

class SoundChannel extends kha.SoundChannel {
	private var channel: flash.media.SoundChannel;
	private var position: Float;
	private var length: Int;
	
	public function new(channel: flash.media.SoundChannel, length: Int) {
		super();
		this.channel = channel;
		this.position = 0;
		this.length = length;
	}
	
	public override function play(): Void {
		super.play();
		//channel.play();
	}
	
	override public function pause(): Void {
		//channel.pause();
	}
	
	public override function stop(): Void {
		channel.stop();
		super.stop();
	}
	
	override public function getLength(): Int {
		return length;
	}
	
	override public function getCurrentPos(): Int {
		if (channel == null) return 0;
		else return Std.int(channel.position);
	}
	
	override public function setVolume(volume:Float):Void {
		channel.soundTransform = new SoundTransform(volume,channel.soundTransform.pan); 
	}
	
	override public function setPan(pan: Float): Void {
		channel.soundTransform = new SoundTransform(channel.soundTransform.volume,pan); 
	}
	
	override public function getPan(): Float {
		return channel.soundTransform.pan;
	}
	
}

/*class Sound extends kha.Sound {
	var sound: flash.media.Sound;
	
	public function new(sound: flash.media.Sound) {
		super();
		this.sound = sound;
	}
	
	public override function play(): SoundChannel {
		return new SoundChannel(sound.play(), Std.int(sound.length));
	}
}*/

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
