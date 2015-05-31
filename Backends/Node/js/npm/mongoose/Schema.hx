package js.npm.mongoose;

extern class Schema<T>
implements npm.Package.RequireNamespace<"mongoose","*"> {

	public static var reserved : Dynamic<Int>;
	public static var indexTypes (default,null) : Array<String>;

	public var tree : Dynamic;
	public var paths : Dynamic<SchemaType>;
	public var methods (default,null) : Dynamic<Dynamic->Dynamic>;
	public function new( definition : {} , ?options : SchemaOptions ) : Void;
	public function defaultOptions( ?options : SchemaOptions ) : SchemaOptions;
	public function add( obj : {} , ?prefix : String ) : Schema<T>;
	public function path( path : String , ?obj : Dynamic ) : Schema<T>;
	public function eachPath( fn : String->Dynamic->Void ) : Schema<T>;
	public function requiredPaths() : Array<String>;
	public function pathType( path : String ) : String;
	public function pre( method : String , fn : ( Void->Void )->Void ) : Schema<T>;
	public function post( method : String , fn : ( Void->Void )->Void ) : Schema<T>;
	public function plugin( fn : Schema<T>->?{}->Void , ?opts : {} ) : Schema<T>;
	@:overload( function( methods : Dynamic<Dynamic<Dynamic->Dynamic>> ) : Schema<T> {} )
	public function method( name : String , fn : Dynamic->Dynamic ) : Schema<T>;
	@:overload( function( methods : Dynamic<Dynamic<Dynamic->Dynamic>> ) : Schema<T> {} )
	public inline function static_( name : String , fn : Dynamic<Dynamic->Dynamic> ) : Schema<T> 
		return untyped this['static'](arguments);
	public function index( fields : {} , ?options : {} ) : Schema<T>;
	@:overload( function( key : String ) : Dynamic {} )
	public function set( key : String , value : Dynamic , ?_tags : Dynamic ) : Schema<T>;
	public function get( key : String ) : Dynamic;
	public function indexes() : Array<Dynamic>;
	public function virtual( name : String , ?options : {} ) : VirtualType;
	public function virtualpath( name : String ) : VirtualType;
}

typedef SchemaOptions = {
	?autoIndex : Bool,
	?bufferCommands : Bool,
	?capped : Bool,
	?collection : String,
	?id : Bool,
	?_id : Bool,
	?minimize : Bool,
	?read : String,
	?safe : Bool,
	?shardKey : Bool,
	?strict : Bool,
	?toJSON : Dynamic,
	?toObject : Dynamic,
	?versionKey : Bool
}