package unityEngine;

@:native('UnityEngine.Input')
extern class Input {
	public static function GetKeyDown(name: String): Bool;
	public static function GetKeyUp(name: String): Bool;
}
