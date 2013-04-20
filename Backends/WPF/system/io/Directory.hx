package system.io;

@:native("System.IO.Directory")
extern class Directory 
{
	public static function CreateDirectory(path : String) :  DirectoryInfo;
}