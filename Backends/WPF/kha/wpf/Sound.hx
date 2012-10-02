package kha.wpf;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class Sound extends kha.Sound {
	var player : MediaElement;
	
	public function new(filename : String) : Void {
		super();
		player = new MediaElement();
		player.LoadedBehavior = MediaState.Manual;
		player.UnloadedBehavior = MediaState.Manual;
		player.Source = new Uri(filename, UriKind.Relative);
	}
	
	public override function play() : Void {
		player.Play();
	}
	
	public override function pause() : Void {
		player.Pause();
	}

	public override function stop() : Void {
		player.Stop();
	}

	@:functionBody('
		if (player.NaturalDuration.HasTimeSpan)
		return Math.round(player.NaturalDuration.TimeSpan.TotalMilliseconds);
		else return int.MaxValue;
	')
	public override function getLength() : Int {
		return 0;
	}
	
	@:functionBody('
		return Math.round(player.Position.TotalMilliseconds);
	')
	public override function getCurrentPos() : Int {
		return 0;
	}
	
	public override function getVolume() : Float {
		return player.Volume;
	}

	public override function setVolume(volume : Float) : Void {
		player.Volume = volume;
	}
}