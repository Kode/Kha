package js.npm;

extern class ConnectMongo
implements npm.Package.Require<"connect-mongo","*"> {
	public function new( expr : Dynamic ) : Void;
	public static inline function store( opts : {} ) : js.npm.connect.session.Store {
		var cm = untyped ConnectMongo(js.npm.Connect);
		return untyped __new__(cm ,opts );
	}
}