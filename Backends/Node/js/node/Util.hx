package js.node;

extern class Util 
implements npm.Package.Require<"fs","*"> {
  public static function debug(s:String):Void;
  public static function inspect(o:Dynamic,?showHidden:Bool,?depth:Int):Void;
  public static function log(s:String):Void;
  //public static function pump(rs:NodeReadStream,ws:NodeWriteStream,cb:Dynamic->Void):Void;
  public static function inherits(constructor:Dynamic,superConstructor:Dynamic):Void;
  public static function isArray(o:Dynamic):Bool;
  public static function isRegExp(o:Dynamic):Bool;
  public static function isDate(o:Dynamic):Bool;
  public static function isError(o:Dynamic):Bool;
  public static function format(out:String,?a1:Dynamic,?a2:Dynamic,?a3:Dynamic):Void; // should be arbitrary # of args
}
