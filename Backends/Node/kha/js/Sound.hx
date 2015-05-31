package kha.js;

class SoundChannel extends kha.SoundChannel {
	public function new() {
		super();
	}
	
	override public function play(): Void {
		super.play();
	}
	
	override public function pause(): Void {
		
	}
	
	override public function stop(): Void {
		super.stop();
	}
	
	override public function getCurrentPos(): Int {
		return 0;
	}
	
	override public function getLength(): Int {
		return 0;
	}
}

class Sound extends kha.Sound {
	public function new() {
		super();
	}
	
	override public function play(): kha.SoundChannel {
		return new SoundChannel();
	}
}

