package js.npm.socketio;

typedef Manager = {

	var sockets(default,null) : Namespace;

	var store(default, null) : Dynamic;
	var log(default, null) : Dynamic;
	@:native("static") var static_(default, null) : Dynamic;

	function get(key : Dynamic) : Dynamic;
	function set(key : Dynamic, value : Dynamic) : Manager;
	function enable(key : Dynamic) : Manager;
	function disable(key : Dynamic) : Manager;

	function enabled(key : Dynamic) : Bool;
	function disabled(key : Dynamic) : Bool;

	@:overload(function(fn : Void -> Void):Manager {})
	@:overload(function(fn : Manager -> Void):Manager {})
	function configure(env : Dynamic, fn : Manager -> Void) : Manager;

	function of(nsp : Dynamic) : Namespace;
}