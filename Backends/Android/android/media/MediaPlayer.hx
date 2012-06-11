package android.media;

extern class MediaPlayer {
	public function new() : Void;
	public function start() : Void;
	public function stop() : Void;
	public function setLooping(b : Bool) : Void;
	public function prepare() : Void;
	public function setDataSource(descriptor : String, offset : Int, length : Int) : Void;
}