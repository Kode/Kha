package js.node;

import js.support.Callback;

extern class Dns 
implements npm.Package.Require<"dns","*"> 
{
  @:overload( function (domain:String,rrtype:String,cb:Callback<Array<Dynamic>>):Void {} )
  static function resolve(domain:String,cb:Callback<Array<Dynamic>>):Void;
  static function resolveNs(domain:String,cb:Callback<Array<Dynamic>>):Void;
  static function resolve4(domain:String,cb:Callback<Array<String>>):Void;
  static function resolve6(domain:String,cb:Callback<String>):Void;
  static function resolveMx(domain:String,cb:Callback<Array<{priority:Int,exchange:String}>>):Void;
  static function resolveSrv(domain:String,cb:Callback<Array<{priority:Int,weight:Int,port:Int,name:String}>>):Void;
  static function resolveCname(domain:String,cb:Callback<Array<String>>):Void;
  static function reverse(ip:String,cb:Callback<Array<String>>):Void;
  static function resolveTxt(domain:String,cb:Callback<Array<String>>):Void;
  @:overload( function (domain:String,family:String,cb:Callback2<String,Int>):Void {} )
  static function lookup(domain:String,cb:Callback2<String,Int>):Void;
}