package kha.wpf;

import kha.audio1.MusicChannel;
import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class Music extends kha.Music{
	//private var player: MediaElement;
	public var filename: String;
	private var channel : MusicChannel;
	
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
		channel = new MusicChannel(filename, loop);
		channel.play();
	}
	
	public override function pause() : Void { channel.pause(); }
	
	public override function stop(): Void { channel.stop(); }

	public override function getLength() : Int { return channel.length; } // Miliseconds
	
	public override function getCurrentPos() : Int { return channel.position; } // Miliseconds
	
	public override function getVolume() : Float { return channel.volume; } // [0, 1]

	public override function setVolume(volume : Float) : Void { channel.volume = volume; } // [0, 1]
	
	override public function isFinished() : Bool { return channel.finished; }
}