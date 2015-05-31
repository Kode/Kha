package js.node;


extern class Repl 
implements npm.Package.Require<"repl","*">  {
	static function start( prompt : String, ?stream : Dynamic ) : Void;
}