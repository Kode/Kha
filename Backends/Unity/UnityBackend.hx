package;

import haxe.io.BytesData;
import unityEngine.Texture2D;

extern class UnityBackend {
	public static function loadImage(filename: String): Texture2D; 
	public static function loadBlob(filename: String): BytesData;
}
