package kha.audio1;

import system.io.Path;
import system.Uri;
import system.UriKind;
import system.windows.controls.MediaElement;
import system.windows.controls.MediaState;

class WpfAudioChannel implements kha.audio1.AudioChannel {
	private var player: MediaElement;
	private var hasFinished: Bool = false;
	
	public function new(filename: String) {
		this.player = new MediaElement();
		addEventHandlers();
		player.LoadedBehavior = MediaState.Manual;
		player.UnloadedBehavior = MediaState.Manual;
		// MediaElement needs Absolute URI. Relative won't work
		player.Source = new Uri(Path.GetFullPath(filename), UriKind.Absolute);
		// TODO: perhaps files should be checked for validity?
		
		play();
	}
	
	public function play(): Void {
		hasFinished = false;
		player.Play();
	}
	
	public function pause(): Void {
		player.Pause();
	}

	public function stop(): Void {
		hasFinished = true;
		player.Stop();
	}

	public var length(get, null): Float;
	
	@:functionCode('
		if (player.NaturalDuration.HasTimeSpan) return player.NaturalDuration.TimeSpan.TotalMilliseconds * 1000.0;
		else return float.MaxValue;
	')
	public function get_length(): Float {
		return 0;
	}
	
	public var position(get, null): Float; // Seconds
	
	@:functionCode('return Math.round(player.Position.TotalMilliseconds) * 1000.0;')
	function get_position(): Float {
		return 0;
	}
	
	public var volume(get, set): Float;
	
	function get_volume(): Float {
		return player.Volume;
	}

	function set_volume(value: Float): Float {
		return player.Volume = value;
	}
	
	public var finished(get, null): Bool;
	
	function get_finished(): Bool {
		return hasFinished;
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
