package kha.audio2;

extern class Audio {
	public static function init();
	public static function shutdown();
	
	public static var audioCallback: Int->Buffer->Void;
}
