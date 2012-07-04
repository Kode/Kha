package kha.flash;

import flash.media.SoundChannel;

class Music extends kha.Music {
	var music : flash.media.Sound;
	var channel : SoundChannel;
	
	public function new(music : flash.media.Sound) {
		super();
		this.music = music;
	}
	
	public override function start() : Void {
		if (channel != null) channel.stop();
		channel = music.play(0, 1000 * 1000 * 100);
	}
	
	public override function stop() : Void {
		if (channel != null) channel.stop();
	}

	public function update() : Void {
		
	}
}