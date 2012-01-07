package com.ktxsoftware.kje.backend.flash;
import flash.media.SoundChannel;

class Music implements com.ktxsoftware.kje.Music {
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
		channel.stop();
	}

	public function update() : Void {
		
	}
}