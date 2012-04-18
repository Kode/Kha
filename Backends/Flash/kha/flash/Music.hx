package kha.flash;

import flash.media.SoundChannel;

class Music implements kha.Music {
	var music : flash.media.Sound;
	var channel : SoundChannel;
	
	public function new(music : flash.media.Sound) {
		this.music = music;
	}
	
	public function start() : Void {
		if (channel != null) channel.stop();
		channel = music.play(0, 1000 * 1000 * 100);
	}
	
	public function stop() : Void {
		if (channel != null) channel.stop();
	}

	public function update() : Void {
		
	}
}