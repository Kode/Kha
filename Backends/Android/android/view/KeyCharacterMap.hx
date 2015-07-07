package android.view;

extern class KeyCharacterMap {
	public static function load(deviceId: Int): KeyCharacterMap;
	public function get(keyCode: Int, metaState: Int): Int;
}
