package js.npm.mongoose;

extern class SchemaType
implements npm.Package.RequireNamespace<"mongoose","*"> {
	public var path (default,null) : String;
	public var instance (default,null) : Dynamic;
	public var validators (default,null) : Array<Dynamic>;
	public var setters (default,null) : Array<Dynamic>;
	public var getters (default,null) : Array<Dynamic>;
	public var _index (default,null) : Null<{}>;
	public var defaultValue(default,null) : Dynamic;
	public var options (default,null) : Dynamic;

	public function new( path : String , options : {} , instance : String ) : Void;
}