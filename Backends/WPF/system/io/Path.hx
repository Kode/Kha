package system.io;

@:native("System.IO.Path")
extern class Path 
{
	public static function GetFullPath(path: String): String;
}
