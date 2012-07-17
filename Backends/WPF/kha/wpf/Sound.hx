package kha.wpf;
import system.Uri;
import system.UriKind;
import system.windows.media.MediaPlayer;

class Sound extends kha.Sound {
	var player : MediaPlayer;
	
	public function new(filename : String) : Void {
		super();
		player = new MediaPlayer();
        player.Open(new Uri(filename, UriKind.Relative));
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