package system;

@:native("System.Uri")
extern class Uri {
	function new(filename : String, kind : UriKind) : Void;
}