package kha.wpf;

import kha.audio1.MusicChannel;
import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class Music extends kha.Music {
	public var filename: String;
	
	public function new(filename: String) : Void {
		super();
		this.filename = filename;
	}
}
