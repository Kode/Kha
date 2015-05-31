package js.npm.mongoose;

import js.npm.mongoose.*;
import js.support.Callback;

extern class Mongoose
implements npm.Package.RequireNamespace<"mongoose","*"> {
	public function new() : Void;
	public var connection (default,null) : Connection;
	public var modelNames (default,null) : Array<String>;
	public var connections (default,null) : Array<Connection>;
	public var version (default,null) : String;

	public function disconnect(cb : Callback0) : Void;
	public function createConnection( url : String ) : Connection;
	public function connect( url : String , ?fn : js.support.Callback0 ) : Mongoose;
	public function model<T,M>( name : String , ?schema : Schema<T> , ?collectionName : String , ?skipInit : Bool ) : Model.TModels<T,M>;
	public function plugin( fn : Dynamic , ?options : {} ) : Mongoose;
}