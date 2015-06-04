package unityEngine;

@:native('UnityEngine.GL')
extern class GL {
	public static function Clear(clearDepth: Bool, clearColor: Bool, backgroundColor: Color, depth: Single): Void;
}
