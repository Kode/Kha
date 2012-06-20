package system.io;

@:native("System.IO.File")
extern class File {
	public static function AppendAllText(path : String, contents : String) : Void;
	public static function ReadAllText(filename : String) : String;
	public static function WriteAllText(path : String, contents : String) : Void;
}