package kha.wpf;

import kha.wpf.Sound.SoundChannel;
import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class Music extends kha.Music{
	//private var player: MediaElement;
	private var filename: String;
	private var soundChannel : SoundChannel;
	
	public function new(filename: String) : Void {
		super();
		this.filename = filename;
		/*player = new MediaElement();
		player.LoadedBehavior = MediaState.Manual;
		player.UnloadedBehavior = MediaState.Manual;
		// MediaElement needs Absolute URI. Relative won't work
		player.Source = new Uri( Path.GetFullPath( filename ), UriKind.Absolute);
		// TODO: perhaps files should be checked for validity? */
	}
	
	public override function play(loop: Bool = false): Void {
		soundChannel = new SoundChannel(filename);
		soundChannel.play();
	}
	
	public override function pause() : Void { soundChannel.pause(); }
	
	public override function stop(): Void { soundChannel.stop(); }

	public override function getLength() : Int { return soundChannel.getLength(); } // Miliseconds
	
	public override function getCurrentPos() : Int { return soundChannel.getCurrentPos(); } // Miliseconds
	
	public override function getVolume() : Float { return soundChannel.getVolume(); } // [0, 1]

	public override function setVolume(volume : Float) : Void { soundChannel.setVolume(volume); } // [0, 1]
	
	override public function isFinished() : Bool { return soundChannel.isFinished(); }
}