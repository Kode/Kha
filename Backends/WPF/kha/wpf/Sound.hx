package kha.wpf;

import kha.SoundChannel;
import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class Sound extends kha.Sound {
	//private var player: MediaElement;
	public var filename: String;
	
	private var channel : SoundChannel;
	
	public function new(filename: String) : Void {
		super();
		this.filename = filename;
	}
	
	public override function play(): SoundChannel {
		// TODO: Does not work, but is deprecated anyway
		//channel = new kha.audio1.SoundChannel(filename);
		channel.play();
		return channel;
	}
}