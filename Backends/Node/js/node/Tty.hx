

extern class Tty 
implements npm.Package.Require<"tty","*"> 
{
  /* returns a non homogenous array of elements, el[0].fd, el[1] is a child process obj
     best check it manually */
  static function open(path:String,args:Dynamic):Array<Dynamic>;
  static function isatty(fd:Int):Bool;
  static function setRawMode(mode:Bool):Void;
  static function setWindowSize(fd:Int,row:Int,col:Int):Void;
  static function getWindowSize(fd:Int):{row:Int,col:Int};
}
