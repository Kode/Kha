package js.node;

extern class Path 
implements npm.Package.Require<"path","*"> 
{
  static var sep:String;
	
  static function join(?p1:String,?p2:String,?p3:String):String;
  static function normalize(p:String):String;
  static function relative(?p1:String,?p2:String,?p3:String):String;
  @:overload(function(?p1:String,?p2:String,?p3:String):String {})
  static function resolve(from:Array<String>,to:String):String;
  static function dirname(p:String):String;
  static function basename(p:String,?ext:String):String;
  static function extname(p:String):String;

  /* deprecated 0.8, use NodeFs equivs instead */
  static function exists(p:String,cb:Bool->Void):Void;
  static function existsSync(p:String):Bool;
}
