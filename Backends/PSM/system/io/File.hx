package system.io;

import haxe.io.BytesData;

@:native("System.IO.File")
extern class File {
	public static function AppendAllText(path: String, contents: String): Void;
	public static function ReadAllText(filename: String): String;
	public static function WriteAllText(path: String, contents: String): Void;
	public static function ReadAllBytes(path: String): BytesData;
	public static function WriteAllBytes(path: String, bytes: BytesData): Void;
	public static function Exists(path: String): Bool;
}
