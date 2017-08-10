package android.media;

extern class MediaFormat {
	public function getInteger(name: String): Int;
	
	public static var KEY_CHANNEL_COUNT: String;
	public static var KEY_SAMPLE_RATE: String;
}