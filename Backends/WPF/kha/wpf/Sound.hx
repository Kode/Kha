package kha.wpf;

import kha.SoundChannel;
import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class Sound extends kha.Sound {
	public var filename: String;
	private var channel : SoundChannel;
	
	public function new(filename: String) : Void {
		super();
		this.filename = filename;
	}
}
