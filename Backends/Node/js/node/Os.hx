package js.node;


extern class Os 
implements npm.Package.Require<"os","*"> 
{
  static function hostname():String;
  static function type():String;
  static function release():String;
  static function uptime():Int;
  static function loadavg():Array<Float>;
  static function totalmem():Int;
  static function freemem():Int;
  static function cpus():Int;
  static function platform():String;
  static function arch():String;
  static function networkInterfaces():Dynamic;
}