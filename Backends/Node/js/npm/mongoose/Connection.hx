package js.npm.mongoose;

typedef Db = Dynamic;

extern class Connection
implements npm.Package.RequireNamespace<"mongoose","*"> {
	public var db : Db;	
}