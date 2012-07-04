package kha.flash;

class Sound extends kha.Sound {
	var sound : flash.media.Sound;
	
	public function new(sound : flash.media.Sound) {
		super();
		this.sound = sound;
	}
	
	public override function start() : Void {
		sound.play(0);
	}
	
	public override function stop() : Void {
		
	}
}