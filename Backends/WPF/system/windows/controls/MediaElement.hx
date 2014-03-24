package system.windows.controls;
import system.Uri;

@:native("System.Windows.Controls.MediaElement")
extern class MediaElement {
	public var Volume : Float;
	public var Source : Uri;
	public var LoadedBehavior : MediaState;
	public var UnloadedBehavior : MediaState;
	
	public var MediaOpened : Dynamic;
	
	public function new() : Void { }
	
	public function Play() : Void { }
	
	public function Pause() : Void { }

	public function Stop() : Void { }
}

@:native("System.Windows.RoutedEventArgs") 
extern class RoutedEventArgs {
	
}