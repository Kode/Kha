package system.io;

@:native("System.IO.File")
extern class File {
	public static function ReadAllText(filename : String) : String;
}