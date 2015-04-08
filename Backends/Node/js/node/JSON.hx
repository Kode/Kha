package js.node;

@:native("JSON")
extern class JSON {

	public static function stringify(data:Dynamic) : String;
	public static function parse(data:String) : Dynamic;
  	
}
 