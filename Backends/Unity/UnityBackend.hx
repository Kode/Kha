package;

import haxe.io.BytesData;
import unityEngine.Texture2D;
import unityEngine.AudioClip;

extern class UnityBackend {
	public static function uvStartsAtTop(): Bool;
	public static function loadImage(filename: String): Texture2D; 
	public static function loadBlob(filename: String): BytesData;
	public static function loadSound(filename: String): AudioClip;
	public static function getImageSize(asset: Texture2D): Point;
}
