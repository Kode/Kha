package js;

@:native("RegExp")
extern class RegExp {

	public var source (default,null) : String;
	
	public var ignoreCase (default,null) : Bool;
	public var global (default,null) : Bool;
	public var multiline (default,null) : Bool;

	public var lastIndex (default,null) : Int;

	public function new( pattern : String , flags : String ) : Void;
	// TODO methods
}