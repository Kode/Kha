package system.windows.media;
import system.DateTime.TimeSpan;

@:native("System.Windows.Media.MediaPlayer")
extern class MediaPlayer {
	public var Volume : Float;
	
	public function new() : Void { }
		
    public function Open(uri : Uri) : Void { }
	
	public function Play() : Void { }
	
	public function Pause() : Void { }

	public function Stop() : Void { }
}