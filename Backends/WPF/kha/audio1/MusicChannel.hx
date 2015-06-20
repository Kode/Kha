package kha.audio1;

import system.windows.controls.MediaElement;

class MusicChannel extends SoundChannel {
	
	private var looping: Bool = false;
	
	public function new(filename : String, looping : Bool) {
		super(filename);
		
		this.looping = looping;
	}
		
	override function OnMediaEnded(obj : Dynamic, e : RoutedEventArgs) {
		if (looping) {
			play();
		}		
		else 
		{
			hasFinished = true;	
		}
	}
}
	