package js.npm.express;

import js.support.Callback;

typedef SessionCookieOptions = {
	?path : String,
	?httpOnly : Bool,
	?secure : Bool,
	?maxAge : Int
}

typedef SessionGenId = Request -> String;

@:enum abstract SessionUnset(String) {
	var Keep = "keep";
	var Destroy = "destroy";
}

typedef SessionOptions = {
	?name : String,
	?store : SessionStore,
	secret : String,
	?cookie : SessionCookieOptions,
	?genid : SessionGenId,
	?rolling : Bool,
	?resave : Bool,
	?proxy : Bool,
	?saveUninitialized : Bool,
	?unset : SessionUnset
}

extern class SessionData 
implements Dynamic {
	var cookie : SessionCookieOptions;
	function regenerate( cb : Callback0 ) : Void;
	function destroy( cb : Callback0 ) : Void;
	function reload( cb : Callback0 ) : Void;
	function save( cb : Callback0 ) : Void;
	function touch( cb : Callback0 ) : Void;
}

interface SessionStore {
	public function get(sid : String, callback : Callback<{}> ) : Void;
	public function set(sid : String, session : {}, callback : Callback0 ) : Void;
	public function destroy(sid : String, callback : Callback0 ) : Void;
}

extern class Session 
implements npm.Package.Require<"express-session","~1.9.3"> #if !haxe3,#end
implements js.npm.connect.Middleware
{
	public function new( opts : SessionOptions ) : Void;

	public inline static function session( req : Request ) : SessionData {
		return untyped req.session;
	}
}