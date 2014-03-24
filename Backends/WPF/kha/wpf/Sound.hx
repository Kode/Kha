package kha.wpf;

import kha.SoundChannel;
import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class SoundChannel extends kha.SoundChannel {
	private var player: MediaElement;
	
	private var hasFinished: Bool = false;
	
	public function new(filename : String) {
		super();
		this.player = new MediaElement();
		addEventHandlers();
		player.LoadedBehavior = MediaState.Manual;
		player.UnloadedBehavior = MediaState.Manual;
		// MediaElement needs Absolute URI. Relative won't work
		player.Source = new Uri( Path.GetFullPath( filename ), UriKind.Absolute);
		// TODO: perhaps files should be checked for validity? 
	}
	
	public override function play(): Void {
		super.play();
		hasFinished = false;
		player.Play();
	}
	
	public override function pause(): Void {
		player.Pause();
	}

	public override function stop(): Void {
		player.Stop();
		super.stop();
	}

	@:functionCode('
		if (player.NaturalDuration.HasTimeSpan)
		return Math.round(player.NaturalDuration.TimeSpan.TotalMilliseconds);
		else return int.MaxValue;
	')
	public override function getLength(): Int {
		return 0;
	}
	
	@:functionCode('
		return Math.round(player.Position.TotalMilliseconds);
	')
	public override function getCurrentPos(): Int {
		return 0;
	}
	
	override public function isFinished():Bool 
	{
		return hasFinished || wasStopped;
	}
	
	public override function getVolume(): Float {
		return player.Volume;
	}

	public override function setVolume(volume: Float): Void {
		player.Volume = volume;
	}
	
	@:functionCode('
		player.MediaEnded += OnMediaEnded;
	')
	function addEventHandlers() {
	}
	
	function OnMediaEnded(obj : Dynamic, e : RoutedEventArgs) {
		hasFinished = true;
	}
}

class Sound extends kha.Sound {
	//private var player: MediaElement;
	private var filename: String;
	
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
	
	public override function play(): kha.SoundChannel {
		var soundChannel = new SoundChannel(filename);
		soundChannel.play();
		return soundChannel;
	}
}