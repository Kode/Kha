package js.browser.youtube;

// Very very incomplete

typedef PlayerOptions = {
	?width : Int,
	?height : Int,
	?videoId : String,
	?playerVars : {},
	?events : {
		?onStateChange : PlayerEvent<PlayerState>->Void,
		?onReady : PlayerEvent<Void>->Void
	}
}

typedef PlayerEvent<T> = {
	target : Player,
	?data : T
}

@:native("YT.PlayerState")
extern class PlayerState {
	public static var ENDED : PlayerState;
	public static var PLAYING : PlayerState;
	public static var PAUSED : PlayerState;
	public static var BUFFERING : PlayerState;
	public static var CUED : PlayerState;
}

@:native("YT.Player")
extern class Player {
	public function new( id : String , options : PlayerOptions ) : Void;
	public function stopVideo() : Void;
	public function playVideo() : Void;
	public function mute():Void;
	public function unMute() : Void;
	public function isMuted() : Bool;
	public function getVolume() : Float;
	public function setVolume( v : Float ):Void;
	public function setSize( w : Float , h : Float ) : Void;
	public function setPlaybackQuality( q : String ) : Void;
	public function getPlaybackQuality() : String;

}