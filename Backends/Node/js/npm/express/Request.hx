package js.npm.express;

import js.node.http.ClientRequest;

typedef Route = Dynamic;
typedef Accepted = Dynamic;

typedef Request = TRequest<Dynamic,Dynamic>;

@:native("Request")
extern class TRequest<P,Q>
extends ClientRequest {

	public var params : P;
	public var query : Q;
	public var route : Route;
	public var accepted : Array<Accepted>;
	public var ip : String;
	public var ips : Array<String>;
	public var path : String;
	public var host : String;
	public var fresh : Bool;
	public var stale : Bool;
	public var xhr : Bool;
	public var protocol : String;
	public var secure : Bool;
	public var subdomains : Array<String>;
	public var originalUrl : String;
	public var acceptedLanguages : Array<String>;
	public var acceptedCharsets : Array<String>;

	public function param( name : String ) : Null<Dynamic>;
	public function get( name : String ) : Null<String>;

	@:overload(function( mimes : Array<String> ) : Null<String> {} )
	public function accepts( mime : String ) : Null<String>;

	public function is( type : String ) : Bool;

	public function acceptsCharset( charset : String ) : Bool;
	public function acceptsLanguage( lang : String ) : Bool;


}