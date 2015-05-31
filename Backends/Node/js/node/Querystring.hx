package js.node;

extern class Querystring 
implements npm.Package.Require<"querystring","*"> 
{
  static function parse(s:String,?sep:String,?eq:String,?options:{maxKeys:Int}):Dynamic;
  static function escape(s:String):String;
  static function unescape(s:String):String;
  static function stringify(obj:Dynamic,?sep:String,?eq:String):String;
}