package com.ktxsoftware.kha.backends.flash;

class Sound implements com.ktxsoftware.kha.Sound {
	var sound : flash.media.Sound;
	
	public function new(sound : flash.media.Sound) {
		this.sound = sound;
	}
	
	public function play() : Void {
		sound.play(0);
	}
	
	public function stop() : Void {
		
	}
}