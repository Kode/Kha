package js.npm;

import js.support.Callback;

extern class Dust 
implements npm.Package.Require<"dustjs-linkedin","">
{
	public static var optimizers (default,null) : {};
	public static var filters (default,null) : {};
	public static var helpers (default,null) : {};
	public static var escapeHtml : String->String;
	public static var escapeJs : String->String;

	public static function compile(source:String,name:String) : Dust;
	public static function compileFn(source:String,?name:String) : Dust;
	public static function render(name:String,context:{},cb:Callback<String>) : Void;
	public static function stream(name:String,context:{}) : js.node.events.EventEmitter;
	public static function makeBase(context:{}) : DustBase;
	public static function register(name:String,fn : Dynamic) : Void;
	public static function onLoad(name:String,cb:Callback<String>) : Void;
	public static function loadSource(source:String,?filename:String) : Dust;
	public static function renderSource(source:String,context:{},?cb:Callback<String>) : Void;
} 

typedef DustBase = {
	function push( context : {} , ?index: Int, ?length: Int ) : Void;
	function get( key : String ) : Dynamic;
	function current() : DustBase;
}

typedef DustChunk = {
	function write(data:String) : DustChunk;
	function map(cb : DustChunk -> Void ) : Void;
	function end(data:String) : Void;
	function tap(cb : Void->Void ) : Void;
	function untap() : Void;
	function render( body: String, context : DustBase ) : String;
	function setError( error : String ) : Void;

	// TODO 
	// chunk.reference(elem, context, auto, filters)
	// chunk.section(elem, context, bodies, params)
	// chunk.exists(elem, context, bodies)
	// chunk.notexists(elem, context, bodies)
	// chunk.block(elem, context, bodies)
	// chunk.partial(elem, context)
	// chunk.helper(name, context, bodies, params)
}