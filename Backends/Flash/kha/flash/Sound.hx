package kha.flash;

import flash.media.SoundChannel;

class Sound extends kha.Sound {
	var sound : flash.media.Sound;
	var channel : SoundChannel;
	var position : Float;
	
	public function new(sound : flash.media.Sound) {
		super();
		this.sound = sound;
		this.channel = null;
		this.position = 0;
	}
	
	public override function play() : Void {
		channel = sound.play(position);
	}
	
	override public function pause() : Void {
		if (channel != null) {
			position = channel.position;
			channel.stop();
		}
	}
	
	public override function stop() : Void {
		if (channel != null) channel.stop();
		position = 0;
	}
	
	override public function getLength() : Int {
		return Std.int(sound.length);
	}
	
	override public function getCurrentPos() : Int {
		if (channel == null) return 0;
		else return Std.int(channel.position);
	}
}