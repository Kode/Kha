package kha.wpf;
import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.media.MediaPlayer;

class Video extends kha.Video {
	var player : MediaPlayer;
	
	public function new(filename : String) : Void {
		super();
		player = new MediaPlayer();
		player.Open(new Uri( Path.GetFullPath( filename ), UriKind.Absolute));
	}
	
	public function getPlayer() : MediaPlayer {
		return player;
	}
	
	public override function play(loop : Bool = false) : Void {
		player.Play();
	}
	
	public override function pause() : Void {
		player.Pause();
	}

	public override function stop() : Void {
		player.Stop();
	}

	@:functionCode('
		if (player.NaturalDuration.HasTimeSpan)
		return Math.round(player.NaturalDuration.TimeSpan.TotalMilliseconds);
		else return int.MaxValue;
	')
	public override function getLength() : Int {
		return 0;
	}
	
	@:functionCode('
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
	
	public override function unload(): Void {
		player = null;
	}
}