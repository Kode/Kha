package kha.audio1;

import system.windows.controls.MediaElement;

class WpfMusicChannel extends WpfSoundChannel implements kha.audio1.MusicChannel {
	private var looping: Bool = false;
	
	public function new(filename: String, looping: Bool) {
		super(filename);
		this.looping = looping;
	}
	
	override function OnMediaEnded(obj: Dynamic, e: RoutedEventArgs): Void {
		if (looping) {
			play();
		}
		else {
			hasFinished = true;
		}
	}
}
