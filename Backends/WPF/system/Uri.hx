package system;

@:native("System")
extern class Uri {
	function new(filename : String, kind : UriKind) : Void;
}